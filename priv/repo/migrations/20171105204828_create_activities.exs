defmodule Squeeze.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities) do
      add :name, :string
      add :distance, :float
      add :duration, :integer
      add :start_at, :naive_datetime
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:activities, [:user_id])
  end
end
