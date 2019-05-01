defmodule Squeeze.Repo.Migrations.AddTrackpointsBelongToSet do
  use Ecto.Migration

  def change do
    alter table(:trackpoints) do
      add :trackpoint_set_id, references(:trackpoint_sets, on_delete: :delete_all), null: false
    end

    create index(:trackpoints, [:trackpoint_set_id])
  end
end
