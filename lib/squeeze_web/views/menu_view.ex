defmodule SqueezeWeb.MenuView do
  use SqueezeWeb, :view

  alias Squeeze.Accounts.User

  def in_trial?(user) do
    user.subscription_status == :trialing
  end
end
