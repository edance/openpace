defmodule SqueezeWeb.HomeView do
  use SqueezeWeb, :view

  def title("namer.html", _), do: gettext("Rename your Strava Activities Automatically")
  def title(_, _), do: gettext("Run Your Best Race Ever")
end
