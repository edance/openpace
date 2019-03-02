defmodule Squeeze.OAuth2.FitbitTest do
  use Squeeze.DataCase

  alias Squeeze.OAuth2.Fitbit

  describe "authorize_url/1" do
    test "includes www.fitbit.com" do
      assert Fitbit.authorize_url! =~ ~r/https:\/\/www.fitbit.com/
    end
  end
end
