defmodule Squeeze.Repo.Migrations.AddSlugToRaceGoals do
  use Ecto.Migration

  def change do
    alter table(:race_goals) do
      add :slug, :string
    end

    # Restrict duplicate slugs for a race_goal
    create unique_index(:race_goals, :slug)
  end
end
