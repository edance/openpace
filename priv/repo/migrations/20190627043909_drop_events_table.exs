defmodule Squeeze.Repo.Migrations.DropEventsTable do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      remove :event_id, references(:events, on_delete: :nothing)
    end

    drop table(:events)
  end
end
