defmodule Squeeze.Repo.Migrations.AddImperialToUserPrefs do
  use Ecto.Migration

  def change do
    alter table(:user_prefs) do
      add :imperial, :boolean, default: false, null: true
    end
  end
end
