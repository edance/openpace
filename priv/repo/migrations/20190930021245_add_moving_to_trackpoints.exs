defmodule Squeeze.Repo.Migrations.AddMovingToTrackpoints do
  use Ecto.Migration

  def change do
    alter table(:trackpoints) do
      add :moving, :boolean
    end
  end
end
