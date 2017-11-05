defmodule Squeeze.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :first_name, :string
      add :last_name, :string
      add :description, :string
      add :avatar, :string
      add :city, :string
      add :state, :string
      add :country, :string

      timestamps()
    end

  end
end
