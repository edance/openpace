defmodule Squeeze.Repo.Migrations.AddNamerFieldsToUserPrefs do
  use Ecto.Migration

  def change do
    alter table(:user_prefs) do
      add :rename_activities, :boolean, default: false, null: false
      add :emoji, :boolean, default: true, null: false
      add :branding, :boolean, default: true, null: false
    end
  end
end
