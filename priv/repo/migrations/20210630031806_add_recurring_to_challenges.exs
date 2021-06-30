defmodule Squeeze.Repo.Migrations.AddRecurringToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :recurring, :boolean, default: false, null: false
    end
  end
end
