defmodule SqueezeWeb.MenuView do
  use SqueezeWeb, :view

  def in_trial?(user) do
    user.subscription_status == :trialing
  end
end
