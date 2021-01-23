defmodule Squeeze.Repo.Migrations.CreatePushTokens do
  use Ecto.Migration

  def change do
    create table(:push_tokens) do
      add :token, :string
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true

      timestamps()
    end

    create index(:push_tokens, [:user_id])
    create unique_index(:push_tokens, [:user_id, :token])
  end
end
