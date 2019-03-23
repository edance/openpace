defmodule Squeeze.Repo.Migrations.AddBreadcrumbsToRaces do
  use Ecto.Migration

  def change do
    alter table(:races) do
      add :distance, :float
      add :distance_type, :integer

      add :overview, :text
    end
  end
end
