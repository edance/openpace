defmodule Squeeze.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :description, :string
      add :image, :string

      timestamps()
    end

  end
end
