defmodule Squeeze.TimeHelper do
  @moduledoc """
  Module to handle time
  """

  alias Squeeze.Accounts.User

  def today(%User{user_prefs: %{timezone: timezone}}) do
    timezone
    |> Timex.now()
    |> Timex.to_date()
  end

  def to_date(%User{user_prefs: %{timezone: timezone}}, datetime \\ Timex.now) do
    datetime
    |> Timex.to_datetime(timezone)
    |> Timex.to_date()
  end
end
