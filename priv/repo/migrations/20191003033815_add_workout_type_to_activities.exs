defmodule Squeeze.Repo.Migrations.AddWorkoutTypeToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :workout_type, :integer
    end
  end
end
