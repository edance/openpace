defmodule SqueezeWeb.StravaWebhookView do
  use SqueezeWeb, :view

  def render("success.json", _) do
    %{}
  end

  def render("challenge.json", %{challenge: challenge}) do
    %{"hub.challenge" => challenge}
  end

  def render("400.json", _) do
    %{}
  end
end
