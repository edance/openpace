defmodule SqueezeWeb.WizardViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :wizard_view_case

  alias SqueezeWeb.WizardView

  test "title includes preferences" do
    assert WizardView.title(%{}, %{}) =~ ~r/preferences/
  end

  test "#distances" do
    {option, value} = WizardView.distances
    |> List.first()
    assert is_binary(option)
    assert is_integer(value)
  end

  describe "#improvement_amount" do
    test "without a personal record" do
      user = build(:user)
      assert WizardView.improvement_amount(user) == nil
    end

    test "returns the percent improvement" do
      user = build(:user, user_prefs: %{duration: 60, personal_record: 120})
      assert WizardView.improvement_amount(user) == "100.0%"
    end
  end
end
