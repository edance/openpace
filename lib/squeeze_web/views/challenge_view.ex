defmodule SqueezeWeb.ChallengeView do
  use SqueezeWeb, :view

  def title("index.html", _assigns), do: "Challenges"
  def title("show.html", %{challenge: challenge}), do: challenge.name
end
