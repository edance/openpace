defmodule SqueezeWeb.LayoutView do
  use SqueezeWeb, :view

  def company_name, do: "OpenPace"
  def copyright_year, do: Date.utc_today.year
  def website_name, do: "OpenPace"
  def website_url, do: "https://www.openpace.co"
end
