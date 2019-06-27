defmodule Squeeze.Repo.Migrations.AddExternalIdToRaces do
  use Ecto.Migration

  def change do
    alter table(:races) do
      add :external_id, :string
    end

    # Restrict duplicate races with the same external id
    create unique_index(:races, [:external_id])
  end
end
