defmodule Squeeze.Repo.Migrations.AddDescriptionToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :description, :text
    end
  end
end
