defmodule Fitbit.Repo.Migrations.CreateCredentials do
  use Ecto.Migration

  def change do
    create table(:credentials) do
      add :provider, :string
      add :uid, :string
      add :token, :string, size: 500
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:credentials, [:user_id])
    create unique_index(:credentials, [:uid, :provider])
  end
end
