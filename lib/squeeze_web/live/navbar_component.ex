defmodule SqueezeWeb.NavbarComponent do
  use SqueezeWeb, :live_component

  alias Squeeze.Accounts.User

  def initials(user) do
    "#{String.at(user.first_name, 0)}#{String.at(user.last_name, 0)}"
  end

  def full_name(user), do: User.full_name(user)
end
