defmodule Squeeze.Repo.Migrations.AddStatusToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :status, :integer, null: false, default: 0
    end
  end
end
