defmodule <%= app_module %>.Auth0API do
  @moduledoc """
  Module for interacting with the Auth0 Management API.
  """

  require Logger

  @doc """
  Get an access token for the Auth0 Management API.
  """
  def get_access_token do
    domain = Application.get_env(:aurora, __MODULE__)[:domain]
    client_id = Application.get_env(:aurora, __MODULE__)[:client_id]
    client_secret = Application.get_env(:aurora, __MODULE__)[:client_secret]

    case Req.post("https://#{domain}/oauth/token",
           json: %{
             client_id: client_id,
             client_secret: client_secret,
             audience: "https://#{domain}/api/v2/",
             grant_type: "client_credentials"
           }
         ) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body["access_token"]}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Failed to get Auth0 token. Status: #{status}, Body: #{inspect(body)}")
        {:error, "Failed to get access token: #{status}"}

      {:error, error} ->
        Logger.error("Error getting Auth0 token: #{inspect(error)}")
        {:error, "Failed to get access token: #{inspect(error)}"}
    end
  end

  @doc """
  Get organization by ID.
  """
  def get_organization(organization_id) do
    with {:ok, token} <- get_access_token(),
         domain = Application.get_env(:aurora, __MODULE__)[:domain],
         {:ok, %{status: 200, body: body}} <-
           Req.get(
             "https://#{domain}/api/v2/organizations/#{organization_id}",
             headers: [
               {"authorization", "Bearer #{token}"},
               {"content-type", "application/json"}
             ]
           ) do
      {:ok, body}
    else
      {:ok, %{status: status, body: body}} ->
        Logger.error("Failed to get organization. Status: #{status}, Body: #{inspect(body)}")
        {:error, "Failed to get organization: #{status}"}

      {:error, error} ->
        Logger.error("Error getting organization: #{inspect(error)}")
        {:error, "Error getting organization: #{inspect(error)}"}
    end
  end

  @doc """
  List organizations.
  """
  def list_organizations do
    with {:ok, token} <- get_access_token(),
         domain = Application.get_env(:aurora, __MODULE__)[:domain],
         {:ok, %{status: 200, body: body}} <-
           Req.get(
             "https://#{domain}/api/v2/organizations",
             headers: [
               {"authorization", "Bearer #{token}"},
               {"content-type", "application/json"}
             ]
           ) do
      {:ok, body}
    else
      {:ok, %{status: status, body: body}} ->
        Logger.error("Failed to list organizations. Status: #{status}, Body: #{inspect(body)}")
        {:error, "Failed to list organizations: #{status}"}

      {:error, error} ->
        Logger.error("Error listing organizations: #{inspect(error)}")
        {:error, "Error listing organizations: #{inspect(error)}"}
    end
  end

  @doc """
  Check if user is a member of an organization.
  """
  def check_organization_member(organization_id, user_id) do
    encoded_user_id = URI.encode_www_form(user_id)
    with {:ok, token} <- get_access_token(),
         domain = Application.get_env(:auth0poc, __MODULE__)[:domain],
         {:ok, %{status: 200, body: body}} <-
           Req.get(
             "https://#{domain}/api/v2/organizations/#{organization_id}/members/#{encoded_user_id}",
             headers: [
               {"authorization", "Bearer #{token}"},
               {"content-type", "application/json"}
             ]
           ) do
      {:ok, body}
    else
      {:ok, %{status: 404}} ->
        {:error, :not_member}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Failed to check membership. Status: #{status}, Body: #{inspect(body)}")
        {:error, "Failed to check membership: #{status}"}

      {:error, error} ->
        Logger.error("Error checking membership: #{inspect(error)}")
        {:error, "Error checking membership: #{inspect(error)}"}
    end
  end

  def get_organization_members(organization_id) do
    with {:ok, token} <- get_access_token(),
      domain = Application.get_env(:aurora, __MODULE__)[:domain],
      {:ok, %{status: 200, body: body}} <- Req.get(
        "https://#{domain}/api/v2/organizations/#{organization_id}/members",
        headers: [
          {"authorization", "Bearer #{token}"},
          {"content-type", "application/json"}
        ]
      ) do
      {:ok, body}
    else
      {:ok, %{status: status, body: body}} ->
        Logger.error("Failed to get users. Status: #{status}, Body: #{inspect(body)}")
        {:error, "Failed to get users: #{status}"}

      {:error, error} ->
        Logger.error("Error getting users: #{inspect(error)}")
        {:error, "Error getting users: #{inspect(error)}"}
    end
  end

  def add_organization_member(org_id, user_id) do
    body=%{
      "members" => [user_id]
    }

    with {:ok, token} <- get_access_token(),
      domain = Application.get_env(:aurora, __MODULE__)[:domain],
      {:ok, %{status: 204, body: body}} <- Req.post(
        "https://#{domain}/api/v2/organizations/#{org_id}/members",
        json: body,
        headers: [
          {"authorization", "Bearer #{token}"},
          {"content-type", "application/json"}
        ]
      ) do
      {:ok, body}
    else
      {:ok, %{status: status, body: body}} ->
        Logger.error("Failed to add user to organization. Status: #{status}, Body: #{inspect(body)}")
        {:error, "Failed to add user to organization: #{status}"}

      {:error, error} ->
        Logger.error("Error adding user to organization: #{inspect(error)}")
        {:error, "Error adding user to organization: #{inspect(error)}"}
    end
  end

  def get_roles do
    with {:ok, token} <- get_access_token(),
      domain = Application.get_env(:aurora, __MODULE__)[:domain],
      {:ok, %{status: 200, body: body}} <- Req.get(
        "https://#{domain}/api/v2/roles",
        headers: [
          {"authorization", "Bearer #{token}"},
          {"content-type", "application/json"}
        ]
      ) do
      {:ok, body}
    else
      {:ok, %{status: status, body: body}} ->
        Logger.error("Failed to get roles. Status: #{status}, Body: #{inspect(body)}")
        {:error, "Failed to get roles: #{status}"}

      {:error, error} ->
        Logger.error("Error getting roles: #{inspect(error)}")
        {:error, "Error getting roles: #{inspect(error)}"}
    end
  end

  def get_users_roles(user_id) do
    encoded_user_id = URI.encode_www_form(user_id)
    with {:ok, token} <- get_access_token(),
      domain = Application.get_env(:aurora, __MODULE__)[:domain],
      {:ok, %{status: 200, body: body}} <- Req.get(
        "https://#{domain}/api/v2/users/#{encoded_user_id}/roles",
        headers: [
          {"authorization", "Bearer #{token}"},
          {"content-type", "application/json"}
        ]
      ) do
      {:ok, body}
    else
      {:ok, %{status: status, body: body}} ->
        Logger.error("Failed to get roles for user. Status: #{status}, Body: #{inspect(body)}")
        {:error, "Failed to get roles for user: #{status}"}

      {:error, error} ->
        Logger.error("Error getting roles for user: #{inspect(error)}")
        {:error, "Error getting roles for user: #{inspect(error)}"}
    end
  end


  def delete_user(user_id) do
    encoded_user_id = URI.encode_www_form(user_id)
    with {:ok, token} <- get_access_token(),
      domain = Application.get_env(:aurora, __MODULE__)[:domain],
      {:ok, %{status: 204}} <- Req.delete(
        "https://#{domain}/api/v2/users/#{encoded_user_id}",
        headers: [
          {"authorization", "Bearer #{token}"},
          {"content-type", "application/json"}
        ]
      ) do
      {:ok, "User deleted successfully"}
    else
      {:ok, %{status: status, body: body}} ->
        Logger.error("Failed to delete user. Status: #{status}, Body: #{inspect(body)}")
        {:error, "Failed to delete user: #{status}"}

      {:error, error} ->
        Logger.error("Error deleting user: #{inspect(error)}")
        {:error, "Error deleting user: #{inspect(error)}"}
    end
  end


  def create_user(email, given_name, name, password) do
    body = %{
      "email" => email,
      "user_metadata" => %{},
      "blocked" => false,
      "email_verified" => false,
      "app_metadata" => %{},
      "given_name" => given_name,
      "name" => name,
      "picture" => "https://www.dpreview.com/sample-galleries/1330372094/fujifilm-x-a3-samples",
      "connection" => "Username-Password-Authentication",
      "password" => password,
      "verify_email" => false
    }

    with {:ok, token} <- get_access_token(),
      domain = Application.get_env(:aurora, __MODULE__)[:domain],
      {:ok, %{status: 201, body: body}} <- Req.post(
        "https://#{domain}/api/v2/users",
        json: body,
        headers: [
          {"authorization", "Bearer #{token}"},
          {"content-type", "application/json"}
        ]
      ) do
      {:ok, body}
    else
      {:ok, %{status: status, body: body}} ->
        Logger.error("Failed to create user. Status: #{status}, Body: #{inspect(body)}")
        {:error, "Failed to create user: #{status}"}

      {:error, error} ->
        Logger.error("Error creating user: #{inspect(error)}")
        {:error, "Error creating user: #{inspect(error)}"}
    end
  end
  def assign_role_to_user(user_id, roles) do
    encoded_user_id = URI.encode_www_form(user_id)
    body=%{
      "roles" => [roles]
    }

    with {:ok, token} <- get_access_token(),
      domain = Application.get_env(:aurora, __MODULE__)[:domain],
      {:ok, %{status: 204, body: body}} <- Req.post(
        "https://#{domain}/api/v2/users/#{encoded_user_id}/roles",
        json: body,
        headers: [
          {"authorization", "Bearer #{token}"},
          {"content-type", "application/json"}
        ]
      ) do
      {:ok, body}
    else
      {:ok, %{status: status, body: body}} ->
        Logger.error("Failed to assign roles to user. Status: #{status}, Body: #{inspect(body)}")
        {:error, "Failed to assign roles to user: #{status}"}

      {:error, error} ->
        Logger.error("Error assigning roles to user: #{inspect(error)}")
        {:error, "Error assigning roles to user: #{inspect(error)}"}
    end
  end
end
