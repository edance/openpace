defmodule SqueezeWeb.BillingViewTest do
  use SqueezeWeb.ConnCase, async: true

  alias SqueezeWeb.BillingView

  test "title/2" do
    assert BillingView.title(%{}, %{}) == "Billing"
  end

  test "formatted_trial_end/1" do
    datetime = Timex.now
    |> Timex.shift(days: 3, minutes: 1)
    opts = %{current_user: %{trial_end: datetime}}

    assert BillingView.formatted_trial_end(opts) == "in 3 days"
  end

  test "card_number/1" do
    opts = %{payment_method: %{last4: "3328"}}

    assert BillingView.card_number(opts) == "•••• •••• •••• 3328"
  end

  describe "card_exp/1" do
    test "with a month before September" do
      opts = %{payment_method: %{exp_month: 2, exp_year: 2020}}

      assert BillingView.card_exp(opts) == "02 / 2020"
    end

    test "with a month after September" do
      opts = %{payment_method: %{exp_month: 12, exp_year: 2020}}

      assert BillingView.card_exp(opts) == "12 / 2020"
    end
  end

  test "due_date/2" do
    user = insert(:user)
    {:ok, datetime} = NaiveDateTime.new(2019, 5, 25, 7, 15, 0)

    assert BillingView.due_date(user, datetime) == "5/25/19"
  end

  test "format_currency/1" do
    assert BillingView.format_currency(2837) == "$28.37"
  end
end
