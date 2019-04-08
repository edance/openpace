defmodule SqueezeWeb.DashboardView do
  use SqueezeWeb, :view

  def title(_page, _assigns) do
    gettext("Dashboard")
  end
end
