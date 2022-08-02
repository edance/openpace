defmodule Squeeze.Repo.Migrations.AddPersonalRecordsToUserPrefs do
  use Ecto.Migration

  def change do
    alter table(:user_prefs) do
      add :personal_records, :map
    end
  end
end
