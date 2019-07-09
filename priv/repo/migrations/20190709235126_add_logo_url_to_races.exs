defmodule Squeeze.Repo.Migrations.AddLogoUrlToRaces do
  use Ecto.Migration

  def change do
    alter table(:races) do
      add :logo_url, :string
    end
  end
end
