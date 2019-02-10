defmodule SqueezeWeb.LayoutView do
  use SqueezeWeb, :view

  def company_name, do: "Squeeze.Run"
  def copyright_year, do: Date.utc_today.year
  def website_name, do: "Squeeze"
  def website_url, do: "https://squeeze.run"
end
