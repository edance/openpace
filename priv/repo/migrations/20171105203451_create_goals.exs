defmodule Squeeze.Repo.Migrations.CreateGoals do
  use Ecto.Migration

  def change do
    create table(:goals) do
      add :distance, :float
      add :duration, :integer
      add :name, :string
      add :date, :date
      add :current, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:goals, [:user_id])
  end
end
