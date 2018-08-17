defmodule Squeeze.Repo.Migrations.ChangeUserPrefsReferenceToUsers do
  use Ecto.Migration

  def up do
    drop constraint(:user_prefs, "user_prefs_user_id_fkey")
    alter table(:user_prefs) do
      modify :user_id, references(:users, on_delete: :delete_all), null: false
    end
  end

  def down do
    drop constraint(:user_prefs, "user_prefs_user_id_fkey")
    alter table(:user_prefs) do
      modify :user_id, references(:users, on_delete: :nothing)
    end
  end
end
