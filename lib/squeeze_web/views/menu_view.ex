defmodule SqueezeWeb.MenuView do
  use SqueezeWeb, :view

  alias Squeeze.Accounts.User

  def authenticated?(user) do
    User.onboarded?(user)
  end

  def full_name(user) do
    "#{user.first_name} #{user.last_name}"
  end

  def copyright_year do
    Date.utc_today.year
  end
end
