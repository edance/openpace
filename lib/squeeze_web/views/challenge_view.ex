defmodule SqueezeWeb.ChallengeView do
  use SqueezeWeb, :view

  def title("show.html", %{challenge: challenge}), do: challenge.name
  def title(_, _assigns), do: "Challenges"
end
