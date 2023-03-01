defmodule Squeeze.Repo.Migrations.AddRaceFieldsToRaceGoals do
  use Ecto.Migration

  def change do
    alter table(:race_goals) do
      add :race_name, :string
      add :description, :string
      add :race_date, :date

      modify :race_id,
             references(:races, on_delete: :nothing),
             null: true,
             from: references(:races, on_delete: :nothing)
    end
  end
end
