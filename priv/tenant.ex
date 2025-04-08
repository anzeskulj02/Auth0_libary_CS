defmodule <%= app_module %>.Tenants.Tenant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tenants" do
    field :name, :string
    field :slug, :string
    field :auth0_organization_id, :string
    field :active, :boolean, default: true

    has_many :users, <%= app_module %>.Accounts.User
    has_one :tenant_data, <%= app_module %>.Tenants.TenantData

    timestamps()
  end

  @doc false
  def changeset(tenant, attrs) do
    tenant
    |> cast(attrs, [:name, :slug, :auth0_organization_id, :active])
    |> validate_required([:name, :slug, :auth0_organization_id])
    |> unique_constraint(:slug)
    |> unique_constraint(:auth0_organization_id)
  end
end
