defmodule Squeeze.Repo.Migrations.AddTokenSecretToCredentials do
  use Ecto.Migration

  def change do
    alter table(:credentials) do
      add :token_secret, :string, size: 500
    end
  end
end
