defmodule Squeeze.Repo.Migrations.CreateChallengeActivities do
  use Ecto.Migration

  def change do
    create table(:challenge_activities) do
      add :amount, :float, null: false

      add :challenge_id, references(:challenges, on_delete: :delete_all), null: false
      add :activity_id, references(:activities, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:challenge_activities, [:challenge_id, :activity_id])
  end
end
