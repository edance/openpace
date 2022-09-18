defmodule SqueezeWeb.MenuView do
  use SqueezeWeb, :view
  @moduledoc false

  def in_trial?(user) do
    user.subscription_status == :trialing
  end
end
