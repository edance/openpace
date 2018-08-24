defmodule SqueezeWeb.DashboardView do
  use SqueezeWeb, :view

  def title(_page, _assigns) do
    "Dashboard"
  end

  def full_name(user) do
    "#{user.first_name} #{user.last_name}"
  end
end
