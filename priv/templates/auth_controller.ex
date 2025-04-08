defmodule <%= app_module %>Web.AuthController do
  use <%= app_module %>Web, :controller
  plug Ueberauth

  alias <%= app_module %>.Accounts
  alias <%= app_module %>.Tenants
  alias <%= app_module %>Web.Guardian

  @doc """
  Retrieves the organization ID from the request params, if present.
  This function is used by Ueberauth via the config
  """
  def get_organization(conn) do
    conn.params["organization"] || nil
  end

  @doc """
  Initiates the Auth0 authentication process.
  """
  def request(conn, params) do
    # Store the organization_id for later use if needed
    org_id = params["organization"]
    # You can optionally store redirect path
    return_to = get_session(conn, :return_to) || "/"

    conn
    |> put_session(:organization_id, org_id)
    |> put_session(:return_to, return_to)
  end

  @doc """
  Handles the Auth0 callback.
  """
  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    org_id = get_session(conn, :organization_id)

    user_params = %{
      auth0_id: auth.uid,
      email: auth.info.email,
      name: auth.info.name,
      picture: auth.info.image
    }

    # Check for organization context
    org_context =
      case auth.extra.raw_info.user["org_id"] do
        nil ->
          # If not provided in token, check if we have it in session
          org_id

        org_id ->
          # Retrieved from token
          org_id
      end

    # If we have organization context, find or create tenant
    tenant =
      if org_context do
        case Tenants.get_tenant_by_auth0_org_id(org_context) do
          nil ->
            # Fetch organization details from Auth0
            with {:ok, org_details} <- <%= app_module %>.Auth0API.get_organization(org_context) do
              # Create tenant record
              {:ok, tenant} =
                Tenants.create_tenant(%{
                  name: org_details["display_name"] || org_details["name"],
                  slug: org_details["name"],
                  auth0_organization_id: org_context,
                  active: true
                })

              # Create default tenant data
              {:ok, _tenant_data} =
                Tenants.create_tenant_data(%{
                  tenant_id: tenant.id,
                  # Default yellow
                  colour: "#FFFF00"
                })

              tenant
            else
              _ -> nil
            end

          tenant ->
            tenant
        end
      else
        nil
      end

    # Get or create user, and associate with tenant if available
    {:ok, user} = Accounts.get_or_create_user(user_params, tenant && tenant.id)

    # Create JWT token
    {:ok, token, _claims} = Guardian.create_session_token(user)

    return_to = get_session(conn, :return_to) || "/"

    user_roles = <%= app_module %>.Auth0API.get_users_roles(user.auth0_id)

    conn
    |> put_flash(:info, "Successfully authenticated.")
    |> put_session(:current_user, user)
    |> put_session(:org, org_context)
    |> put_session(:auth_token, token)
    |> put_session(:user_roles, user_roles)
    |> configure_session(renew: true)
    |> redirect(to: return_to)
  end

  def logout(conn, _params) do
    auth0_domain = Application.get_env(:ueberauth, Ueberauth.Strategy.Auth0.OAuth)[:domain]
    client_id = Application.get_env(:ueberauth, Ueberauth.Strategy.Auth0.OAuth)[:client_id]
    return_to_url = url(~p"/")

    # Construct the Auth0 logout URL
    logout_url =
      "https://#{auth0_domain}/v2/logout?client_id=#{client_id}&returnTo=#{URI.encode_www_form(return_to_url)}"

    conn
    |> configure_session(drop: true)
    |> redirect(external: logout_url)
  end
end
