defmodule Squeeze.Repo.Migrations.AddActivityToRaceGoals do
  use Ecto.Migration

  def change do
    alter table(:race_goals) do
      add :activity_id, references(:activities, on_delete: :delete_all)
    end

    create unique_index(:race_goals, [:activity_id])
  end
end
