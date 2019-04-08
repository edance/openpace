defmodule Squeeze.Repo.Migrations.AddTypeToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :type, :string
    end
  end
end
