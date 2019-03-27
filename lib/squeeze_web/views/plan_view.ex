defmodule SqueezeWeb.PlanView do
  use SqueezeWeb, :view

  def title(_page, _assigns) do
    "Build your training plan"
  end

  def brand_name, do: "OpenPace"
end
