defmodule Squeeze.ChallengeFactory do
  @moduledoc false

  alias Faker.NaiveDateTime
  alias Squeeze.Challenges.Challenge

  defmacro __using__(_opts) do
    quote do
      def challenge_factory do
        {activity, _} = Enum.random(ActivityTypeEnum.__enum_map__())
        {type, _} = Enum.random(ChallengeTypeEnum.__enum_map__())
        {timeline, _} = Enum.random(TimelineEnum.__enum_map__())

        name = [timeline, activity, type, :challenge]
        |> Enum.map(&Atom.to_string/1)
        |> Enum.map(&String.capitalize/1)
        |> Enum.join(" ")

        user = build(:user)

        %Challenge{
          activity_type: activity,
          challenge_type: type,
          timeline: timeline,
          name: name,
          start_at: NaiveDateTime.forward(1),
          user: user
        }
      end

      def with_scores(%Challenge{} = challenge, count \\ 5) do
        scores = insert_list(count, :score, challenge: challenge)
        %{challenge | scores: scores}
      end
    end
  end
end
