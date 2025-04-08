defmodule <%= app_module %>.Repo.Migrations.CreateTenants do
  use Ecto.Migration

  def change do
    create table(:tenants) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :auth0_organization_id, :string, null: false
      add :active, :boolean, default: true, null: false

      timestamps()
    end

    create unique_index(:tenants, [:slug])
    create unique_index(:tenants, [:auth0_organization_id])
  end
end
