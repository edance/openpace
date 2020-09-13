defmodule Squeeze.ScoreFactory do
  @moduledoc false

  alias Squeeze.Challenges.Score

  defmacro __using__(_opts) do
    quote do
      def score_factory do
        %Score{
          score: :rand.uniform(500),
          challenge: build(:challenge),
          user: build(:user)
        }
      end
    end
  end
end
