defmodule SqueezeWeb.SidebarView do
  use SqueezeWeb, :view

  def full_name(user) do
    "#{user.first_name} #{user.last_name}"
  end
end
