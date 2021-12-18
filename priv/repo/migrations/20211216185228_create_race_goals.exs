defmodule Squeeze.Repo.Migrations.CreateRaceGoals do
  use Ecto.Migration

  def change do
    create table(:race_goals) do
      add :duration, :integer
      add :just_finish, :boolean, default: false, null: false

      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :race_id, references(:races, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:race_goals, [:user_id])
    create index(:race_goals, [:race_id])
  end
end
