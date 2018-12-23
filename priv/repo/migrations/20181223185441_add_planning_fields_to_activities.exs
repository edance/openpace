defmodule Squeeze.Repo.Migrations.AddPlanningFieldsToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :planned_distance, :float
      add :planned_duration, :integer
      add :planned_date, :date
    end
  end
end
