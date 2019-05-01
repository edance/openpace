defmodule Squeeze.Repo.Migrations.RemoteActivityFromTrackpoints do
  use Ecto.Migration

  def up do
    drop index(:trackpoints, [:activity_id])
    alter table(:trackpoints) do
      remove :activity_id
    end
  end

  def down do
    alter table(:trackpoints) do
      add :activity_id, references(:activities, on_delete: :delete_all), null: false
    end

    create index(:trackpoints, [:activity_id])
  end
end
