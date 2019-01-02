defmodule Squeeze.Repo.Migrations.AddCompleteToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :complete, :boolean, default: false, null: false
    end
  end
end
