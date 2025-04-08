defmodule <%= app_module %>.Tenants.TenantData do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tenant_data" do
    field :colour, :string
    field :company_name, :string
    field :contact_email, :string
    field :subscription_level, :string
    field :max_users, :integer
    field :welcome_message, :string

    belongs_to :tenant, <%= app_module %>.Tenants.Tenant

    timestamps()
  end

  @doc false
  def changeset(tenant_data, attrs) do
    tenant_data
    |> cast(attrs, [
      :tenant_id,
      :colour,
      :company_name,
      :contact_email,
      :subscription_level,
      :max_users,
      :welcome_message
    ])
    |> validate_required([:tenant_id, :colour])
    |> unique_constraint(:tenant_id)
  end
end
