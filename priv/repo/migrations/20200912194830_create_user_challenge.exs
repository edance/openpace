defmodule Squeeze.Repo.Migrations.CreateUserChallenge do
  use Ecto.Migration

  def change do
    create table(:user_challenge, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all), primary_key: true
      add :challenge_id, references(:challenges, on_delete: :delete_all), primary_key: true
    end

    create index(:user_challenge, [:user_id])
    create index(:user_challenge, [:challenge_id])

    create unique_index(:user_challenge, [:user_id, :challenge_id], name: :user_id_challenge_id_unique_index)
  end
end
