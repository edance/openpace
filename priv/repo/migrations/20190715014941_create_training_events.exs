defmodule Squeeze.Repo.Migrations.CreateTrainingEvents do
  use Ecto.Migration

  def change do
    create table(:training_events) do
      add :name, :string
      add :distance, :float
      add :duration, :integer

      add :warmup, :boolean, default: false, null: false
      add :cooldown, :boolean, default: false, null: false

      add :plan_position, :integer, default: 0
      add :day_position, :integer, default: 0

      add :training_plan_id, references(:training_plans, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:training_events, [:training_plan_id])
  end
end
