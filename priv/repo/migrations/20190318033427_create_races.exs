defmodule Squeeze.Repo.Migrations.CreateRaces do
  use Ecto.Migration

  def change do
    create table(:races) do
      add :name, :string, null: false
      add :slug, :string, null: false

      add :description, :string

      add :city, :string
      add :state, :string
      add :country, :string

      add :url, :string

      timestamps()
    end

    create unique_index(:races, :slug)
  end
end
