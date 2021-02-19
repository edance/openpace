defmodule Squeeze.Repo.Migrations.AddDatesToChallenges do
  use Ecto.Migration

  def up do
    alter table(:challenges) do
      add :start_date, :date
      add :end_date, :date
    end
  end

  def down do
    alter table(:challenges) do
      remove :start_date, :date
      remove :end_date, :date
    end
  end
end
