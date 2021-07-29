defmodule Squeeze.Repo.Migrations.CreateFollows do
  use Ecto.Migration

  def change do
    create table(:follows) do
      add :follower_id, references(:users, on_delete: :delete_all)
      add :followee_id, references(:users, on_delete: :delete_all)
      add :pending, :boolean, null: false, default: false

      timestamps()
    end

    create index(:follows, [:follower_id])
    create index(:follows, [:followee_id])

    # Restrict duplicate follows
    create unique_index(:follows, [:follower_id, :followee_id])
  end
end
