defmodule Squeeze.Repo.Migrations.ChangePolylineToText do
  use Ecto.Migration

  def up do
    alter table(:activities) do
      modify :polyline, :text
    end
  end

  def down do
    alter table(:activities) do
      modify :polyline, :string
    end
  end
end
