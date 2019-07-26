defmodule SqueezeWeb.ModalView do
  use SqueezeWeb, :view

  def run_types do
    [
      %{value: "Run", label: "Run"},
      %{value: "Bike", label: "Bike"},
      %{value: "Swim", label: "Swim"},
      %{value: "Cross Training", label: "Cross Training"},
      %{value: "Walk", label: "Walk"},
      %{value: "Strength Training", label: "Strength Training"},
      %{value: "Workout", label: "Workout"}
    ]
  end
end
