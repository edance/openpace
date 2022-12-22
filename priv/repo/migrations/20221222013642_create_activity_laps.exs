defmodule Squeeze.Repo.Migrations.CreateActivityLaps do
  use Ecto.Migration

  def change do
    create table(:activity_laps) do
      add :average_cadence, :float
      add :average_speed, :float
      add :distance, :float
      add :elapsed_time, :integer
      add :start_index, :integer
      add :end_index, :integer
      add :lap_index, :integer
      add :max_speed, :float
      add :moving_time, :integer
      add :name, :string
      add :pace_zone, :integer
      add :split, :integer
      add :start_date, :naive_datetime
      add :start_date_local, :naive_datetime
      add :total_elevation_gain, :float
      add :activity_id, references(:activities, on_delete: :delete_all)

      timestamps()
    end

    create index(:activity_laps, [:activity_id])
    create unique_index(:activity_laps, [:split, :activity_id], name: :activity_laps_split_activity_id_index)
  end
end
