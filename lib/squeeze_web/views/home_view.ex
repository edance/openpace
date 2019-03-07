defmodule SqueezeWeb.HomeView do
  use SqueezeWeb, :view

  def title(_, _), do: gettext("Juice up your run")
end
