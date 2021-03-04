defmodule Squeeze.Repo.Migrations.AddSlugToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :slug, :string
    end

    # Restrict duplicate slugs for a user
    create unique_index(:users, :slug)
  end
end
