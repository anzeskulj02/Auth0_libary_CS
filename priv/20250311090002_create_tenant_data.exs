defmodule <%= app_module %>.Repo.Migrations.CreateTenantData do
  use Ecto.Migration

  def change do
    create table(:tenant_data) do
      add :tenant_id, references(:tenants, on_delete: :delete_all), null: false
      add :colour, :string, null: false
      add :company_name, :string
      add :contact_email, :string
      add :subscription_level, :string
      add :max_users, :integer
      add :welcome_message, :text

      timestamps()
    end

    create unique_index(:tenant_data, [:tenant_id])
  end
end
