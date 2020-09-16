defmodule Squeeze.Repo.Migrations.AddShareFieldsToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :slug, :string
      add :private, :boolean, default: false, null: false
    end

    # Restrict duplicate slugs for a challenge
    create unique_index(:challenges, :slug)
  end
end
