defmodule Squeeze.Repo.Migrations.AddDistanceUnitToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :planned_distance_unit, :integer
      add :distance_unit, :integer
    end
  end
end
