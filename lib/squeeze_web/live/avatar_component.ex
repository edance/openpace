defmodule SqueezeWeb.AvatarComponent do
  use SqueezeWeb, :live_component
  @moduledoc false

  @colors ~w(
    blue-500
    violet-500
    purple
    pink-500
    red-500
    orange-500
    yellow-500
    green-500
    teal-500
    cyan-500
  )

  def avatar_size(%{size: size}), do: "avatar-#{size}"
  def avatar_size(_), do: "h-8 w-8"

  def position(%{position: p}), do: "#{p}"
  def position(_), do: "relative"

  def bg_color(user) do
    idx = rem(user.id, length(@colors))
    color = Enum.at(@colors, idx)
    "bg-#{color}"
  end

  def class_list(%{user: user} = assigns) do
    [
      avatar_size(user),
      bg_color(user),
      position(assigns),
      "rounded-full content-center overflow-hidden"
    ]
    |> Enum.join(" ")
  end
end
