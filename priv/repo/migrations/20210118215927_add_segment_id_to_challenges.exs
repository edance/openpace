defmodule Squeeze.Repo.Migrations.AddSegmentIdToChallenges do
  use Ecto.Migration

  def change do
    alter table(:challenges) do
      add :segment_id, :string
    end
  end
end
