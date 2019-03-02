defmodule Squeeze.OAuth2.FacebookTest do
  use Squeeze.DataCase

  alias Squeeze.OAuth2.Facebook

  describe "authorize_url/1" do
    test "includes facebook.com" do
      assert Facebook.authorize_url! =~ ~r/https:\/\/www.facebook.com/
    end
  end
end
