defmodule Squeeze.Repo.Migrations.AddActivityTypeToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :activity_type, :integer
    end
  end
end
