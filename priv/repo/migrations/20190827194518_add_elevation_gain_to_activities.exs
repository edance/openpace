defmodule Squeeze.Repo.Migrations.AddElevationGainToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :elevation_gain, :float
    end
  end
end
