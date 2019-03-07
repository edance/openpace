defmodule SqueezeWeb.PageView do
  use SqueezeWeb, :view

  def title("terms.html", _), do: gettext("Terms and Conditions")
  def title("privacy_policy.html", _), do: gettext("Privacy Policy")

  def company_name, do: "Squeeze.Run"
  def website_name, do: "Squeeze.Run"
  def website_url, do: "https://squeeze.run"
end
