defmodule SqueezeWeb.ProfileView do
  use SqueezeWeb, :view

  alias Squeeze.Accounts.User
  alias Squeeze.Distances

  def title(_page, _assigns) do
    "Profile"
  end

  def full_name(%User{} = user), do: User.full_name(user)

  def hometown(%User{city: city, state: state}) do
    "#{city}, #{state}"
  end

  def distances do
    Distances.distances
    |> Enum.map(fn(x) -> {x.name, x.distance} end)
  end
end
