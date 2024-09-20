defmodule Squeeze.Repo.Migrations.CreateTrackpointSections do
  use Ecto.Migration

  def change do
    create table(:trackpoint_sections) do
      add :distance, :float
      add :duration, :integer
      add :velocity, :float

      add :heartrate, :integer
      add :cadence, :integer
      add :power, :integer

      add :section_index, :integer, null: false

      add :activity_id, references(:activities, on_delete: :delete_all)
    end

    create index(:trackpoint_sections, [:activity_id])
    create unique_index(:trackpoint_sections, [:section_index, :activity_id])
  end
end
