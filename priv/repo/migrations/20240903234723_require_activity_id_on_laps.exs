defmodule Squeeze.Repo.Migrations.RequireActivityIdOnLaps do
  use Ecto.Migration

  def up do
    execute """
      DELETE FROM activity_laps WHERE activity_id IS NULL;
    """

    drop constraint(:activity_laps, "activity_laps_activity_id_fkey")

    alter table(:activity_laps) do
      modify :activity_id, references(:activities, on_delete: :delete_all), null: false
    end
  end

  def down do
    drop constraint(:activity_laps, "activity_laps_activity_id_fkey")

    alter table(:activity_laps) do
      modify :activity_id, references(:activities, on_delete: :delete_all), null: true
    end
  end
end
