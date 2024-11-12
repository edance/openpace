defmodule Squeeze.Repo.Migrations.AddRawDataToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :raw_data, :map
    end
  end
end
