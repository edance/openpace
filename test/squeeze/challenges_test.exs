defmodule Squeeze.ChallengesTest do
  use Squeeze.DataCase

  alias Squeeze.Challenges

  describe "challenges" do
    alias Squeeze.Challenges.Challenge

    @valid_attrs %{activity_type: "some activity_type", challenge_type: "some challenge_type", end_at: ~N[2010-04-17 14:00:00], name: "some name", start_at: ~N[2010-04-17 14:00:00], timeline: "some timeline"}
    @update_attrs %{activity_type: "some updated activity_type", challenge_type: "some updated challenge_type", end_at: ~N[2011-05-18 15:01:01], name: "some updated name", start_at: ~N[2011-05-18 15:01:01], timeline: "some updated timeline"}
    @invalid_attrs %{activity_type: nil, challenge_type: nil, end_at: nil, name: nil, start_at: nil, timeline: nil}

    def challenge_fixture(attrs \\ %{}) do
      {:ok, challenge} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Challenges.create_challenge()

      challenge
    end

    test "list_challenges/0 returns all challenges" do
      challenge = challenge_fixture()
      assert Challenges.list_challenges() == [challenge]
    end

    test "get_challenge!/1 returns the challenge with given id" do
      challenge = challenge_fixture()
      assert Challenges.get_challenge!(challenge.id) == challenge
    end

    test "create_challenge/1 with valid data creates a challenge" do
      assert {:ok, %Challenge{} = challenge} = Challenges.create_challenge(@valid_attrs)
      assert challenge.activity_type == "some activity_type"
      assert challenge.challenge_type == "some challenge_type"
      assert challenge.end_at == ~N[2010-04-17 14:00:00]
      assert challenge.name == "some name"
      assert challenge.start_at == ~N[2010-04-17 14:00:00]
      assert challenge.timeline == "some timeline"
    end

    test "create_challenge/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Challenges.create_challenge(@invalid_attrs)
    end

    test "update_challenge/2 with valid data updates the challenge" do
      challenge = challenge_fixture()
      assert {:ok, %Challenge{} = challenge} = Challenges.update_challenge(challenge, @update_attrs)
      assert challenge.activity_type == "some updated activity_type"
      assert challenge.challenge_type == "some updated challenge_type"
      assert challenge.end_at == ~N[2011-05-18 15:01:01]
      assert challenge.name == "some updated name"
      assert challenge.start_at == ~N[2011-05-18 15:01:01]
      assert challenge.timeline == "some updated timeline"
    end

    test "update_challenge/2 with invalid data returns error changeset" do
      challenge = challenge_fixture()
      assert {:error, %Ecto.Changeset{}} = Challenges.update_challenge(challenge, @invalid_attrs)
      assert challenge == Challenges.get_challenge!(challenge.id)
    end

    test "delete_challenge/1 deletes the challenge" do
      challenge = challenge_fixture()
      assert {:ok, %Challenge{}} = Challenges.delete_challenge(challenge)
      assert_raise Ecto.NoResultsError, fn -> Challenges.get_challenge!(challenge.id) end
    end

    test "change_challenge/1 returns a challenge changeset" do
      challenge = challenge_fixture()
      assert %Ecto.Changeset{} = Challenges.change_challenge(challenge)
    end
  end
end
