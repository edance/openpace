defmodule Squeeze.Repo.Migrations.AddSyncAtToCredentials do
  use Ecto.Migration

  def change do
    alter table(:credentials) do
      add :sync_at, :utc_datetime
    end
  end
end
