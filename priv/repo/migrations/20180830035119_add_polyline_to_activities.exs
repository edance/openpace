defmodule Squeeze.Repo.Migrations.AddPolylineToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :polyline, :string
    end
  end
end
