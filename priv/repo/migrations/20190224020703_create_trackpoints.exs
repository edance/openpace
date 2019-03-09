defmodule Squeeze.Repo.Migrations.CreateTrackpoints do
  use Ecto.Migration

  def change do
    create table(:trackpoints) do
      add :altitude, :float
      add :distance, :float
      add :heartrate, :integer
      add :velocity, :float
      add :cadence, :integer
      add :coordinates, :map
      add :time, :integer
      add :activity_id, references(:activities, on_delete: :delete_all), null: false
    end

    create index(:trackpoints, [:activity_id])
  end
end
