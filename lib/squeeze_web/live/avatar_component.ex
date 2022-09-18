defmodule SqueezeWeb.AvatarComponent do
  use SqueezeWeb, :live_component
  @moduledoc false

  @colors ~w(
    blue
    indigo
    purple
    pink
    red
    orange
    yellow
    green
    teal
    cyan
  )

  def avatar_size(%{size: size}), do: "avatar-#{size}"
  def avatar_size(_), do: "avatar-sm"

  def position(%{position: p}), do: "position-#{p}"
  def position(_), do: "position-relative"

  def bg_color(user) do
    idx = rem(user.id, length(@colors))
    color = Enum.at(@colors, idx)
    "bg-gradient-#{color}"
  end

  def class_list(%{user: user} = assigns) do
    ["avatar", avatar_size(assigns), bg_color(user), position(assigns), "text-bold rounded-circle"]
    |> Enum.join(" ")
  end
end
