defmodule Squeeze.Repo.Migrations.CreateFollowers do
  use Ecto.Migration

  def change do
    create table(:followers) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :follows_id, references(:users, on_delete: :delete_all)
      add :pending, :boolean, null: false, default: false

      timestamps()
    end

    create index(:followers, [:user_id])
    create index(:followers, [:follows_id])

    # Restrict duplicate follows
    create unique_index(:followers, [:user_id, :follows_id])
  end
end
