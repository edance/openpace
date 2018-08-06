defmodule Squeeze.Repo.Migrations.CreateUserPrefs do
  use Ecto.Migration

  def change do
    create table(:user_prefs) do
      add :distance, :float
      add :duration, :integer
      add :personal_record, :integer
      add :name, :string
      add :race_date, :date
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:user_prefs, [:user_id])
  end
end
