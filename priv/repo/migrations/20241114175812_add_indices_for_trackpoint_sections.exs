defmodule Squeeze.Repo.Migrations.AddIndicesForTrackpointSections do
  use Ecto.Migration

  def change do
    create index(:trackpoint_sections, [:activity_id, :velocity, :duration, :distance],
             name: "idx_trackpoint_sections_velocity_activity"
           )

    create index(:activities, [:user_id, :start_at_local, :status, :type],
             name: "idx_activities_user_complete_run",
             where: "status = 1 AND type = 'Run'"
           )
  end
end
