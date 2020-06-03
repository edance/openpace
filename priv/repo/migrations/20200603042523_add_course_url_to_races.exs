defmodule Squeeze.Repo.Migrations.AddCourseUrlToRaces do
  use Ecto.Migration

  def change do
    alter table(:races) do
      add :course_url, :string
    end
  end
end
