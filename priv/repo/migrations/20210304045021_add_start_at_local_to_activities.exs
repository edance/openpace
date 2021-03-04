defmodule Squeeze.Repo.Migrations.AddStartAtLocalToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :start_at_local, :naive_datetime
    end
  end
end
