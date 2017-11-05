defmodule Squeeze.Repo.Migrations.CreatePaces do
  use Ecto.Migration

  def change do
    create table(:paces) do
      add :name, :string
      add :offset, :integer
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:paces, [:user_id])
  end
end
