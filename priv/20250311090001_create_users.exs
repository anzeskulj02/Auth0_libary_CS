defmodule <%= app_module %>.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :name, :string
      add :auth0_id, :string, null: false
      add :picture, :string
      add :tenant_id, references(:tenants, on_delete: :nilify_all)

      timestamps()
    end

    create unique_index(:users, [:auth0_id])
    create index(:users, [:tenant_id])
    create index(:users, [:email])
  end
end
