defmodule Squeeze.TimeHelper do
  @moduledoc """
  Module to handle time
  """

  alias Squeeze.Accounts.User

  def today(%User{} = user), do: to_date(user)

  def to_date(%User{user_prefs: %{timezone: timezone}}, datetime \\ Timex.now) do
    datetime
    |> Timex.to_datetime(timezone)
    |> Timex.to_date()
  end

  def beginning_of_day(%User{user_prefs: %{timezone: timezone}}, date) do
    date
    |> Timex.to_datetime(timezone)
    |> Timex.beginning_of_day()
    |> Timex.to_datetime()
  end

  def end_of_day(%User{user_prefs: %{timezone: timezone}}, date) do
    date
    |> Timex.to_datetime(timezone)
    |> Timex.end_of_day()
    |> Timex.to_datetime()
  end
end
