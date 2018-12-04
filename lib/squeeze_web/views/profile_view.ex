defmodule SqueezeWeb.ProfileView do
  use SqueezeWeb, :view

  alias Squeeze.Accounts.User

  def title(_page, _assigns) do
    "Profile"
  end

  def full_name(%User{} = user), do: User.full_name(user)

  def hometown(%User{city: city, state: state}) do
    "#{city}, #{state}"
  end
end
