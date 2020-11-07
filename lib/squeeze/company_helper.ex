defmodule Squeeze.CompanyHelper  do
  @moduledoc """
  Module to handle company name and other similar strings.
  """

  def company_name, do: "OpenPace"
  def team_email, do: {"The OpenPace Team", "team@openpace.co"}
  def copyright_year, do: Date.utc_today.year
  def website_name, do: "OpenPace"
  def website_url, do: "https://www.openpace.co"
end
