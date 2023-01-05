defmodule Squeeze.Repo.Migrations.AddApiEnabledToUserPrefs do
  use Ecto.Migration

  def change do
    alter table(:user_prefs) do
      add :api_enabled, :boolean, default: false, null: false
    end
  end
end
