defmodule SqueezeWeb.StravaWebhookView do
  use SqueezeWeb, :view

  def render("challenge.json", %{challenge: challenge}) do
    %{"hub.challenge" => challenge}
  end

  def render(_, _) do
    %{}
  end
end
