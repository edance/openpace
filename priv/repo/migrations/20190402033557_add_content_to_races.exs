defmodule Squeeze.Repo.Migrations.AddContentToRaces do
  use Ecto.Migration

  def change do
    alter table(:races) do
      add :content, :text
    end
  end
end
