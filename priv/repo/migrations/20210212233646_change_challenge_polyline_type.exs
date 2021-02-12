defmodule Squeeze.Repo.Migrations.ChangeChallengePolylineType do
  use Ecto.Migration

  def up do
    alter table(:challenges) do
      modify :polyline, :text
    end
  end

  def down do
    alter table(:challenges) do
      modify :polyline, :string
    end
  end
end
