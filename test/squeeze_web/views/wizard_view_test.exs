defmodule SqueezeWeb.WizardViewTest do
  use SqueezeWeb.ConnCase, async: true

  @moduletag :wizard_view_case

  require IEx

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
  end
end
