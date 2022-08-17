defmodule Squeeze.Repo.Migrations.CreateTrackpointSections do
  use Ecto.Migration

  def change do
    create table(:trackpoint_sections) do
      add :velocity, :float, null: false
      add :distance, :float, null: false
      add :duration, :integer, null: false
      add :activity_id, references(:activities, on_delete: :nothing)
    end

    create index(:trackpoint_sections, [:activity_id])
  end
end
