defmodule Squeeze.Repo.Migrations.AddQualifierToRaces do
  use Ecto.Migration

  def change do
    alter table(:races) do
      add :boston_qualifier, :boolean
      add :active, :boolean
    end
  end
end
