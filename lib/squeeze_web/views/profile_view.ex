defmodule SqueezeWeb.ProfileView do
  use SqueezeWeb, :view

  def title(_page, _assigns) do
    "Profile"
  end

  def full_name(user) do
    "#{user.first_name} #{user.last_name}"
  end

  def hometown(user) do
    "#{user.city}, #{user.state}"
  end
end
