defmodule Squeeze.Repo.Migrations.AddDescriptionToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :description, :text
    end
  end
end
