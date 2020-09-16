defmodule SqueezeWeb.ChallengeShareView do
  use SqueezeWeb, :view

  def title(_page, _assigns) do
    gettext("Challenge Invite")
  end
end
