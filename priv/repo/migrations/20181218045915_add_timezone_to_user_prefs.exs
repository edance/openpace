defmodule Squeeze.Repo.Migrations.AddTimezoneToUserPrefs do
  use Ecto.Migration

  def change do
    alter table(:user_prefs) do
      add :timezone, :string
    end
  end
end
