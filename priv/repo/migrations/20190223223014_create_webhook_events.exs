defmodule Squeeze.Repo.Migrations.CreateWebhookEvents do
  use Ecto.Migration

  def change do
    create table(:webhook_events) do
      add :provider, :string
      add :provider_id, :string
      add :body, :text

      timestamps()
    end
  end
end
