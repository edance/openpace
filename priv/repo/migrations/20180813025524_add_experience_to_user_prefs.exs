defmodule Squeeze.Repo.Migrations.AddExperienceToUserPrefs do
  use Ecto.Migration

  def change do
    alter table(:user_prefs) do
      add :experience, :integer
    end
  end
end
