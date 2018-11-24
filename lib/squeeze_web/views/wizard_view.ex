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

  def improvement_amount(%User{user_prefs: %{personal_record: nil}}), do: nil
  def improvement_amount(%User{user_prefs: prefs}) do
    personal_record = prefs.personal_record
    percent = abs(personal_record - prefs.duration) / personal_record * 100
    "#{Decimal.round(Decimal.new(percent), 1)}%"
  end
end
