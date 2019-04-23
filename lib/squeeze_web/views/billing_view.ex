defmodule SqueezeWeb.BillingView do
  use SqueezeWeb, :view

  def title(_page, _assigns) do
    "Billing"
  end

  def formatted_trial_end(%{current_user: %{trial_end: trial_end}}) do
    relative_time(trial_end)
  end
end
