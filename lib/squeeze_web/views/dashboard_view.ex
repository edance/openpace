defmodule SqueezeWeb.DashboardView do
  use SqueezeWeb, :view

  alias Squeeze.Distances
  alias Squeeze.Accounts.User

  require IEx

  def title(_page, _assigns) do
    "Dashboard"
  end

  def full_name(user) do
    "#{user.first_name} #{user.last_name}"
  end

  def race_name(user) do
    distance = user.user_prefs.distance
    %{name: name} = Distances.from_meters(distance)
    name
  end

  def improvement_amount(%User{user_prefs: %{personal_record: nil}}), do: nil
  def improvement_amount(%User{user_prefs: prefs}) do
    personal_record = prefs.personal_record
    percent = abs(personal_record - prefs.duration) / personal_record * 100
    "#{Decimal.round(Decimal.new(percent), 1)}%"
  end

  def format_goal(user) do
    user.user_prefs.duration
    |> format_duration()
  end

  def format_date(user) do
    user.user_prefs.race_date
    |> relative_time()
  end
end
