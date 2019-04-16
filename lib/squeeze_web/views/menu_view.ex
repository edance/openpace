defmodule SqueezeWeb.MenuView do
  use SqueezeWeb, :view

  alias Squeeze.Accounts.User

  def authenticated?(user) do
    User.onboarded?(user)
  end

  def in_trial?(user) do
    user.subscription_status == :trialing
  end

  def full_name(%User{} = user), do: User.full_name(user)

  def copyright_year do
    Date.utc_today.year
  end

  def topbar(assigns, do: contents) do
    assigns = Map.merge(assigns, %{yield: contents})
    render("topbar.html", assigns)
  end
end
