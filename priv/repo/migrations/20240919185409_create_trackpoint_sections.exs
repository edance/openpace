defmodule Squeeze.Repo.Migrations.CreateTrackpointSections do
  use Ecto.Migration

  def change do
    create table(:trackpoint_sections) do
      add :distance, :float
      add :duration, :integer
      add :velocity, :float

      add :activity_id, references(:activities, on_delete: :delete_all)
    end

    create index(:trackpoint_sections, [:activity_id])
  end
end
