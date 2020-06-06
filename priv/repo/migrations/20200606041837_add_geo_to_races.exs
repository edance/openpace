defmodule Squeeze.Repo.Migrations.AddGeoToRaces do
  use Ecto.Migration

  def change do
    alter table(:races) do
      add :latitude, :decimal
      add :longitude, :decimal
    end
  end
end
