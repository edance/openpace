defmodule Squeeze.Repo.Migrations.AddGenderBdayToUserPrefs do
  use Ecto.Migration

  def change do
    alter table(:user_prefs) do
      add :gender, :integer
      add :birthdate, :date
    end
  end
end
