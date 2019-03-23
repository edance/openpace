defmodule Squeeze.Repo.Migrations.AddStartAtToRaces do
  use Ecto.Migration

  def change do
    alter table(:races) do
      add :start_at, :naive_datetime
      add :timezone, :string
    end
  end
end
