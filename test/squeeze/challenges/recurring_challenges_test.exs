defmodule Squeeze.RecurringChallengesTest do
  use Squeeze.DataCase

  import Squeeze.Factory
  import Ecto.Query, warn: false
  alias Squeeze.Challenges
  alias Squeeze.Challenges.Challenge
  alias Squeeze.Challenges.RecurringChallenges
  alias Squeeze.Repo

  describe "#find_and_create" do
    test "creates a new challenge and adds the users" do
      challenge = insert(:recurring_challenge) |> with_scores()
      start_date = challenge.start_date
      end_date = challenge.end_date
      now = end_date

      RecurringChallenges.find_and_create(now)

      query = from c in Challenge,
        where: c.start_date >= ^Timex.shift(start_date, days: 7),
        where: c.end_date <= ^Timex.shift(end_date, days: 7),
        where: c.timeline == :week

      Repo.all(query)

      assert [challenge] = Repo.all(query)
      assert scores = Challenges.list_scores(challenge)
      assert length(scores) == 5
      assert Enum.all?(scores, &(&1.amount == 0))
    end
  end
end
