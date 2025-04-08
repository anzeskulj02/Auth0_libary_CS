defmodule <%= app_module %>.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias <%= app_module %>.Repo

  alias <%= app_module %>.Accounts.User
  alias <%= app_module %>.Tenants.Tenant

  @doc """
  Returns the list of users.
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Returns the list of users for a tenant.
  """
  def list_users_by_tenant(tenant_id) do
    User
    |> where([u], u.tenant_id == ^tenant_id)
    |> Repo.all()
  end

  @doc """
  Gets a single user.
  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a user by Auth0 ID.
  """
  def get_user_by_auth0_id(auth0_id) do
    User
    |> Repo.get_by(auth0_id: auth0_id)
    |> Repo.preload(:tenant)
  end

  @doc """
  Creates a user.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Gets or creates a user from Auth0 data, and associates them with a tenant.
  """
  def get_or_create_user(auth0_user, tenant_id \\ nil) do
    case get_user_by_auth0_id(auth0_user.auth0_id) do
      nil ->
        user_params = %{
          email: auth0_user.email,
          name: auth0_user.name,
          auth0_id: auth0_user.auth0_id,
          picture: auth0_user.picture,
          tenant_id: tenant_id
        }

        {:ok, user} = create_user(user_params)
        {:ok, %{user | tenant: tenant_id && Repo.get(Tenant, tenant_id)}}

      user ->
        # Update user info if needed
        updated_params = %{
          name: auth0_user.name,
          picture: auth0_user.picture,
          tenant_id: tenant_id || user.tenant_id
        }

        {:ok, user} = update_user(user, updated_params)
        {:ok, user}
    end
  end
end
