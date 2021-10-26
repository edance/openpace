defmodule Squeeze.Repo.Migrations.AddTrackpointsJsonToTrackpointSets do
  use Ecto.Migration

  def change do
    alter table(:trackpoint_sets) do
      add :trackpoints, :map
    end
  end
end
