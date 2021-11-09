defmodule SqueezeWeb.MenuView do
  use SqueezeWeb, :view

  alias Squeeze.Accounts.User

  def authenticated?(user) do
    User.onboarded?(user)
  end

  def in_trial?(user) do
    user.subscription_status == :trialing
  end

  def on_calendar?(conn) do
    conn.request_path == Routes.calendar_path(conn, :show, :month)
  end

  def full_name(%User{} = user), do: User.full_name(user)
end
