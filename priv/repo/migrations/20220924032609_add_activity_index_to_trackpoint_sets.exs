defmodule Squeeze.Repo.Migrations.AddActivityIndexToTrackpointSets do
  use Ecto.Migration

  def up do
    drop index(:trackpoint_sets, [:activity_id])
    create unique_index(:trackpoint_sets, [:activity_id])
  end

  def down do
    drop unique_index(:trackpoint_sets, [:activity_id])
    create index(:trackpoint_sets, [:activity_id])
  end
end
