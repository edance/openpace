defmodule Squeeze.Repo.Migrations.RemovePacesFromEvents do
  use Ecto.Migration

  def up do
    drop index(:events, [:pace_id])

    alter table(:events) do
      remove :pace_id
    end
  end

  def down do
    alter table(:events) do
      add :pace_id, references(:paces, on_delete: :delete_all), null: false
    end

    create index(:events, [:pace_id])
  end
end
