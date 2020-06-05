defmodule Squeeze.Repo.Migrations.AddStartDateToRaces do
  use Ecto.Migration

  def change do
    alter table(:races) do
      add :start_date, :date
    end
  end
end
