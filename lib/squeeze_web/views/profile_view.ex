defmodule SqueezeWeb.ProfileView do
  use SqueezeWeb, :view

  alias Squeeze.Distances

  def title(_page, _assigns) do
    gettext("Profile")
  end

  def distances do
    Distances.distances
    |> Enum.map(fn(x) -> {x.name, x.distance} end)
  end

  def integration?(provider, %{credentials: credentials}) do
    Enum.any?(credentials, &(&1.provider == provider))
  end

  def membership_status(%{current_user: user}) do
    case user.subscription_status do
      :free -> "Free Account"
      _status -> "Premium Account"
    end
  end
end
