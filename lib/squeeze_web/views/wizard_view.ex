defmodule SqueezeWeb.WizardView do
  use SqueezeWeb, :view

  alias Squeeze.Accounts.User
  alias Squeeze.Distances

  def title(_page, _assigns) do
    "Update your preferences"
  end

  def distances do
    Distances.distances
    |> Enum.map(fn(x) -> {x.name, x.distance} end)
  end

  def improvement_amount(%User{} = user), do: User.improvement_amount(user)
end
