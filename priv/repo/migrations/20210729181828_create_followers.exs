defmodule Squeeze.Repo.Migrations.CreateFollows do
  use Ecto.Migration

  def change do
    create table(:follows) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :follows_id, references(:users, on_delete: :delete_all)
      add :pending, :boolean, null: false, default: false

      timestamps()
    end

    create index(:follows, [:user_id])
    create index(:follows, [:follows_id])

    # Restrict duplicate follows
    create unique_index(:follows, [:user_id, :follows_id])
  end
end
