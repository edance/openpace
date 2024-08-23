defmodule Squeeze.Races.ResultSummary do
  @moduledoc false

  use Ecto.Schema

  alias Squeeze.Duration
  alias Squeeze.Races.Race

  schema "race_result_summaries" do
    field :distance, :float
    field :distance_name, :string
    field :start_date, :date

    field :finisher_count, :integer

    field :male_winner_time, Duration
    field :female_winner_time, Duration
    field :male_avg_time, Duration
    field :female_avg_time, Duration

    belongs_to :race, Race

    timestamps()
  end
end
