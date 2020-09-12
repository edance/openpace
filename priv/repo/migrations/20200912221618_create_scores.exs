defmodule Squeeze.Repo.Migrations.CreateScores do
  use Ecto.Migration

  def change do
    create table(:scores) do
      add :score, :integer, null: false, default: 0
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :challenge_id, references(:challenges, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:scores, [:user_id])
    create index(:scores, [:challenge_id])

    create unique_index(:scores, [:user_id, :challenge_id])
  end
end
