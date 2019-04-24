defmodule SqueezeWeb.BillingView do
  use SqueezeWeb, :view

  alias Number.Currency
  alias Squeeze.TimeHelper

  def title(_page, _assigns) do
    "Billing"
  end

  def formatted_trial_end(%{current_user: %{trial_end: trial_end}}) do
    relative_time(trial_end)
  end

  def due_date(user, date) do
    user
    |> TimeHelper.to_date(date)
    |> Timex.format!("%-m/%-d/%y", :strftime)
  end

  def format_currency(amount) do
    Currency.number_to_currency(amount / 100.0)
  end
end
