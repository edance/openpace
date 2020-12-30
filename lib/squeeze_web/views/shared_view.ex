defmodule SqueezeWeb.SharedView do
  use SqueezeWeb, :view

  def initials(%{user: user}) do
    "#{String.at(user.first_name, 0)}#{String.at(user.last_name, 0)}"
  end
end
