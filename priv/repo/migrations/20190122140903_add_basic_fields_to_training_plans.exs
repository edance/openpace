defmodule Squeeze.Repo.Migrations.AddBasicFieldsToTrainingPlans do
  use Ecto.Migration

  def change do
    alter table(:training_plans) do
      add :experience_level, :integer, default: 0, null: false
      add :week_count, :integer, null: false
      add :description, :text
    end
  end
end
