defmodule Squeeze.Repo.Migrations.AddEmailToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :email, :string
    end

    # Restrict duplicate emails for a user
    create unique_index(:users, :email)
  end
end
