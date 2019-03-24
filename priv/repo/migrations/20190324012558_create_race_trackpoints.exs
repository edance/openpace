defmodule Squeeze.Repo.Migrations.CreateRaceTrackpoints do
  use Ecto.Migration

  def change do
    create table(:race_trackpoints) do
      add :altitude, :float
      add :coordinates, :map
      add :distance, :float

      add :race_id, references(:races, on_delete: :delete_all), null: false
    end

    create index(:race_trackpoints, [:race_id])
  end
end
