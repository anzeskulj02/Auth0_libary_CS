defmodule <%= app_module %>.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :auth0_id, :string
    field :picture, :string

    belongs_to :tenant, <%= app_module %>.Tenants.Tenant

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :auth0_id, :picture, :tenant_id])
    |> validate_required([:email, :auth0_id])
    |> unique_constraint(:auth0_id)
  end
end
