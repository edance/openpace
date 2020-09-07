defmodule Squeeze.Repo.Migrations.CreateChallenges do
  use Ecto.Migration

  def change do
    create table(:challenges) do
      add :name, :string
      add :start_at, :naive_datetime
      add :end_at, :naive_datetime
      add :activity_type, :integer
      add :challenge_type, :integer
      add :timeline, :integer

      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:challenges, [:user_id])
  end
end
