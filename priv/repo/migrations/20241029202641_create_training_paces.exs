defmodule Squeeze.Repo.Migrations.CreateTrainingPaces do
  use Ecto.Migration

  def change do
    create table(:training_paces) do
      add(:color, :string)
      add(:name, :string)
      add(:min_speed, :float)
      add(:max_speed, :float)

      add(:race_goal_id, references(:race_goals, on_delete: :delete_all), null: false)

      timestamps()
    end

    create index(:training_paces, [:min_speed])
    create index(:training_paces, [:max_speed])

    create index(:training_paces, [:race_goal_id])
  end
end
