defmodule Squeeze.Repo.Migrations.AddCourseProfileToRaces do
  use Ecto.Migration

  def change do
    alter table(:races) do
      add :certified, :boolean
      add :course_profile, :integer
      add :course_terrain, :integer
      add :course_type, :integer
    end
  end
end
