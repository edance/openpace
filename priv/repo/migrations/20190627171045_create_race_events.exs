defmodule Squeeze.Repo.Migrations.CreateRaceEvents do
  use Ecto.Migration

  def change do
    create table(:race_events) do
      add :name, :string
      add :details, :text
      add :start_at, :naive_datetime

      add :distance, :float
      add :distance_name, :string

      add :race_id, references(:races, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:race_events, [:race_id])
  end
end
