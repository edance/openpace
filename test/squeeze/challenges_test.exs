defmodule Squeeze.ChallengesTest do
  use Squeeze.DataCase

  import Squeeze.Factory

  alias Ecto.Changeset
  alias Squeeze.Challenges
  alias Squeeze.Challenges.{Challenge, Score}

  describe "#list_challenges/1" do
    test "includes only the users challenge" do
      [score, _] = insert_pair(:score)
      challenges = Challenges.list_challenges(score.user)
      assert Enum.map(challenges, &(&1.id)) == [score.challenge_id]
    end
  end

  describe "#get_challenge_by_slug!/1" do
    test "returns the challenge if found" do
      challenge = insert(:challenge)
      assert challenge.slug == Challenges.get_challenge_by_slug!(challenge.slug).slug
    end

    test "raises error if challenge not found" do
      assert_raise Ecto.NoResultsError, fn ->
        Challenges.get_challenge_by_slug!("abc") end
    end
  end

  describe "#list_matched_challenges/1" do
    test "filters by activity type" do
      # [score, _] = insert_pair(:score)
    end

    test "includes challenges that start at the end of the day" do
      today = Timex.today()
      challenge = insert(:challenge, start_date: today, end_date: today)
      |> with_scores(1)
      [score] = challenge.scores

      end_of_day = Timex.now("America/New_York") |> Timex.end_of_day()
      activity = insert(:activity, user: score.user) |> at_datetime(end_of_day)

      challenges = Challenges.list_matched_challenges(activity)
      assert length(challenges) == 1
      assert List.first(challenges).id == score.challenge_id
    end

    test "excludes challenges that start at after end_date" do
      today = Timex.today()
      challenge = insert(:challenge, start_date: today, end_date: today)
      |> with_scores(1)
      [score] = challenge.scores

      start_of_tomorrow = Timex.now("America/New_York") |> Timex.shift(days: 1) |> Timex.beginning_of_day()
      activity = insert(:activity, user: score.user) |> at_datetime(start_of_tomorrow)

      challenges = Challenges.list_matched_challenges(activity)
      assert Enum.empty?(challenges)
    end

    test "excludes challenges that start at before start_date" do
      today = Timex.today()
      challenge = insert(:challenge, start_date: today, end_date: today)
      |> with_scores(1)
      [score] = challenge.scores

      start_of_yesterday = Timex.now("America/New_York") |> Timex.shift(days: -11) |> Timex.beginning_of_day()
      activity = insert(:activity, user: score.user) |> at_datetime(start_of_yesterday)

      challenges = Challenges.list_matched_challenges(activity)
      assert Enum.empty?(challenges)
    end

    test "returns challenges for user" do
      [score, _] = insert_pair(:score)
      activity = insert(:activity, user: score.user)
      challenges = Challenges.list_matched_challenges(activity)
      assert length(challenges) == 1
      assert List.first(challenges).id == score.challenge_id
    end
  end

  describe "#create_challenge/2" do
    test "with valid data creates a challenge" do
      user = insert(:user)
      params = params_for(:challenge)
      assert {:ok, %Challenge{}} = Challenges.create_challenge(user, params)
    end
  end

  describe "#add_user_to_challenge/2" do
    test "creates a score for the user" do
      user = insert(:user)
      challenge = insert(:challenge)
      assert {:ok, %Score{}} = Challenges.add_user_to_challenge(user, challenge)
    end

    test "returns error if user already added" do
      score = insert(:score)
      user = score.user
      challenge = score.challenge
      assert {:error, %Changeset{}} = Challenges.add_user_to_challenge(user, challenge)
    end
  end
end
