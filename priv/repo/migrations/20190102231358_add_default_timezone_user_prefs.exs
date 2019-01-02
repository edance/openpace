defmodule Squeeze.Repo.Migrations.AddDefaultTimezoneUserPrefs do
  use Ecto.Migration

  def up do
    execute """
      UPDATE user_prefs SET timezone = 'America/New_York' WHERE timezone IS NULL;
    """

    alter table(:user_prefs) do
      modify :timezone, :string, default: "America/New_York", null: false
    end
  end

  def down do
    alter table(:user_prefs) do
      modify :timezone, :string, default: nil, null: true
    end
  end
end
