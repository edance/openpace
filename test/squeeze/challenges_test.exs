defmodule Squeeze.ChallengesTest do
  use Squeeze.DataCase

  import Squeeze.Factory

  alias Squeeze.Challenges
  alias Squeeze.Challenges.Challenge

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

  describe "#create_challenge/2" do
    test "with valid data creates a challenge" do
      user = insert(:user)
      params = params_for(:challenge)
      assert {:ok, %Challenge{}} = Challenges.create_challenge(user, params)
    end
  end
end
