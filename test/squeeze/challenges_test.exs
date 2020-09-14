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

  describe "#get_challenge!/2" do
    test "returns the challenge if found" do
      score = insert(:score)
      user = score.user
      assert score.challenge_id == Challenges.get_challenge!(user, score.challenge_id).id
    end

    test "raises error if challenge does not belong to user" do
      challenge = insert(:challenge)
      user = insert(:user)
      assert_raise Ecto.NoResultsError, fn ->
        Challenges.get_challenge!(user, challenge.id) end
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
