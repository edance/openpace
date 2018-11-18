defmodule Squeeze.Repo.Migrations.AddRefreshTokenToCredentials do
  use Ecto.Migration

  def change do
    alter table(:credentials) do
      add :access_token, :string, size: 500
      add :refresh_token, :string, size: 500
    end
  end
end
