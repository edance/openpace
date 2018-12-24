defmodule Squeeze.Time do
  @moduledoc """
  Module to handle time
  """

  alias Squeeze.Accounts.User

  def today(%User{user_prefs: %{timezone: timezone}}) do
    timezone
    |> Timex.now()
    |> Timex.to_date()
  end
end
