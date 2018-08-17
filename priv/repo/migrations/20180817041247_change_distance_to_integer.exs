defmodule Squeeze.Repo.Migrations.ChangeDistanceToInteger do
  use Ecto.Migration

  def up do
    alter table(:user_prefs) do
      modify :distance, :integer
    end
  end

  def down do
    alter table(:user_prefs) do
      modify :distance, :float
    end
  end
end
