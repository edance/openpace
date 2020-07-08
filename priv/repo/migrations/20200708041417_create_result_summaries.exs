defmodule Squeeze.Repo.Migrations.CreateResultSummaries do
  use Ecto.Migration

  def change do
    create table(:race_result_summaries) do
      add :distance, :float
      add :distance_name, :string
      add :start_date, :date
      add :finisher_count, :integer
      add :male_winner_time, :integer
      add :female_winner_time, :integer
      add :male_avg_time, :integer
      add :female_avg_time, :integer

      add :race_id, references(:races, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:race_result_summaries, [:race_id])
  end
end
