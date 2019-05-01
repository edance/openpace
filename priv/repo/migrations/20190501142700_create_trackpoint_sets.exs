defmodule Squeeze.Repo.Migrations.CreateTrackpointSets do
  use Ecto.Migration

  def change do
    create table(:trackpoint_sets) do
      add :activity_id, references(:activities, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:trackpoint_sets, [:activity_id])
  end
end
