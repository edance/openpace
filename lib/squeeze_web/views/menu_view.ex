defmodule SqueezeWeb.MenuView do
  use SqueezeWeb, :view

  alias Squeeze.Accounts.User

  def authenticated?(user) do
    User.onboarded?(user)
  end

  def full_name(%User{} = user), do: User.full_name(user)

  def copyright_year do
    Date.utc_today.year
  end
end
