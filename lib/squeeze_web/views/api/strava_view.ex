defmodule SqueezeWeb.Api.StravaView do
  use SqueezeWeb, :view

  def render("credential.json", %{credential: credential}) do
    %{
      provider: credential.provider,
      uid: credential.uid
    }
  end
end
