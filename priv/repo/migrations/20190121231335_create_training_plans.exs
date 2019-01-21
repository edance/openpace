defmodule Squeeze.Repo.Migrations.CreateTrainingPlans do
  use Ecto.Migration

  def change do
    create table(:training_plans) do
      add :name, :string
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:training_plans, [:user_id])
  end
end
