defmodule Squeeze.Repo.Migrations.AddDistanceAmountToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :planned_distance_amount, :float
      add :distance_amount, :float
    end
  end
end
