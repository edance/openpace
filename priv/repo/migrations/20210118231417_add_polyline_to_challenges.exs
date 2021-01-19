defmodule Squeeze.Repo.Migrations.AddPolylineToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :polyline, :string
    end
  end
end
