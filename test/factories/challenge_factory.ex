defmodule Squeeze.ChallengeFactory do
  @moduledoc false

  alias Faker.Date
  alias Squeeze.Challenges.Challenge

  defmacro __using__(_opts) do
    quote do
      def challenge_factory do
        {type, _} = Enum.random(ChallengeTypeEnum.__enum_map__())
        {timeline, _} = Enum.random(TimelineEnum.__enum_map__())

        name = [timeline, type, :challenge]
        |> Enum.map(&Atom.to_string/1)
        |> Enum.map_join(" ", &String.capitalize/1)

        user = build(:user)

        %Challenge{
          activity_type: :run,
          slug: sequence(:slug, &("#{&1}")),
          challenge_type: type,
          timeline: timeline,
          name: name,
          segment_id: "12345",
          polyline: "12345",
          start_date: Date.backward(1),
          end_date: Date.forward(10),
          recurring: false,
          user: user
        }
      end

      def recurring_challenge_factory do
        start_date = Timex.today() |>  Timex.beginning_of_week() |> Timex.to_date()
        end_date = start_date |> Timex.end_of_week() |> Timex.to_date()
        struct!(
          challenge_factory(),
          %{
            recurring: true,
            timeline: :week,
            challenge_type: :distance,
            start_date: start_date,
            end_date: end_date,
          }
        )
      end

      def future_challenge_factory do
        struct!(
          challenge_factory(),
          %{
            start_date: Date.forward(1),
            end_date: Date.forward(10),
          }
        )
      end

      def with_scores(%Challenge{} = challenge, count \\ 5) do
        scores = insert_list(count, :score, challenge: challenge)
        %{challenge | scores: scores}
      end
    end
  end
end
