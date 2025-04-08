defmodule <%= app_module %>.Tenants do
  @moduledoc """
  The Tenants context.
  """

  import Ecto.Query, warn: false
  alias <%= app_module %>.Repo

  alias <%= app_module %>.Tenants.Tenant
  alias <%= app_module %>.Tenants.TenantData

  @doc """
  Returns the list of tenants.
  """
  def list_tenants do
    Repo.all(Tenant)
  end

  @doc """
  Gets a single tenant.
  """
  def get_tenant(id), do: Repo.get(Tenant, id)

  @doc """
  Gets a single tenant by auth0_organization_id.
  """
  def get_tenant_by_auth0_org_id(auth0_organization_id) do
    Repo.get_by(Tenant, auth0_organization_id: auth0_organization_id)
  end

  @doc """
  Gets a single tenant by slug.
  """
  def get_tenant_by_slug(slug) do
    Repo.get_by(Tenant, slug: slug)
  end

  @doc """
  Creates a tenant.
  """
  def create_tenant(attrs \\ %{}) do
    %Tenant{}
    |> Tenant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tenant.
  """
  def update_tenant(%Tenant{} = tenant, attrs) do
    tenant
    |> Tenant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tenant.
  """
  def delete_tenant(%Tenant{} = tenant) do
    Repo.delete(tenant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tenant changes.
  """
  def change_tenant(%Tenant{} = tenant, attrs \\ %{}) do
    Tenant.changeset(tenant, attrs)
  end

  # TenantData functions

  @doc """
  Gets tenant_data for a tenant.
  """
  def get_tenant_data(tenant_id) do
    Repo.get_by(TenantData, tenant_id: tenant_id)
  end

  @doc """
  Gets tenant with preloaded tenant_data.
  """
  def get_tenant_with_data(id) do
    Tenant
    |> Repo.get(id)
    |> Repo.preload(:tenant_data)
  end

  @doc """
  Creates tenant_data.
  """
  def create_tenant_data(attrs \\ %{}) do
    %TenantData{}
    |> TenantData.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates tenant_data.
  """
  def update_tenant_data(%TenantData{} = tenant_data, attrs) do
    tenant_data
    |> TenantData.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tenant_data changes.
  """
  def change_tenant_data(%TenantData{} = tenant_data, attrs \\ %{}) do
    TenantData.changeset(tenant_data, attrs)
  end
end
