defmodule Squeeze.OAuth2.GoogleTest do
  use Squeeze.DataCase

  alias Squeeze.OAuth2.Google

  describe "authorize_url/1" do
    test "includes accounts.google.com" do
      assert Google.authorize_url! =~ ~r/https:\/\/accounts.google.com/
    end
  end
end
