defmodule Squeeze.Repo.Migrations.AddElapsedTimeToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :moving_time, :integer
      add :elapsed_time, :integer
    end
  end
end
