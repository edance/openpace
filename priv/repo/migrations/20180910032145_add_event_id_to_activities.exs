defmodule Squeeze.Repo.Migrations.AddEventIdToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :event_id, references(:events, on_delete: :nothing)
    end

    create index(:activities, [:event_id])
  end
end
