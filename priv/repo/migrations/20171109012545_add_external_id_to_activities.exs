defmodule Squeeze.Repo.Migrations.AddExternalIdToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :external_id, :integer, null: false
    end

    # Restrict duplicate activities per user
    create unique_index(:activities, [:user_id, :external_id])
  end
end
