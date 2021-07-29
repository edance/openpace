defmodule Squeeze.RecurringChallengesTest do
  use Squeeze.DataCase

  import Squeeze.Factory
  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Squeeze.Challenges
  alias Squeeze.Challenges.{Challenge, Score}
  alias Squeeze.Repo

  describe "#find_and_create" do
    it "creates a new challenge and adds the users" do
      start_date = Timex.today() |>  Timex.start_of_week() |> Timex.to_date()
      end_date = start_date |> Timex.end_of_week() |> Timex.to_date()
      now = Timex.today() |>  Timex.end_of_week()

      attrs = %{
        recurring: true,
        timeline: :week,
        challenge_type: :distance,
        start_date: start_date,
        end_date: end_date
      }

      challenge = insert(:challenge, attrs)
      |> with_scores()

      RecurringChallenges.find_and_create(now)

      query = from c in Challenge,
        where: c.start_date >= ^Timex.shift(start_date, days: 7),
        where: c.end_date <= ^Timex.shift(end_date, days: 7),
        where: c.timeline == :week

      challenges = Repo.all(query)

      assert [challenge] = Repo.all(query)
      assert scores = Challenges.list_scores(challenge)
      assert length(scores) == 5
      assert Enum.all?(scores, &(&1.amount == 0))
    end
  end
end
