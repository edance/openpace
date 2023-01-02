defmodule Squeeze.Repo.Migrations.AddSlugToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :slug, :string
    end

    # Restrict duplicate slugs for a activities
    create unique_index(:activities, :slug)
  end
end
