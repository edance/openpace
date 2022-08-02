defmodule Squeeze.Repo.Migrations.AddTrainingInformationToRaceGoals do
  use Ecto.Migration

  def change do
    alter table(:race_goals) do
      add :training_paces, :map
      add :distance, :float
    end
  end
end
