defmodule Squeeze.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :email, :string
      add :type, :string

      timestamps()
    end
  end
end
