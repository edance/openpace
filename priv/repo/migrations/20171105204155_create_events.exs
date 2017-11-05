defmodule Squeeze.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string
      add :distance, :float
      add :date, :date
      add :warmup, :boolean, default: false, null: false
      add :cooldown, :boolean, default: false, null: false
      add :pace_id, references(:paces, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:events, [:pace_id])
    create index(:events, [:user_id])
  end
end
