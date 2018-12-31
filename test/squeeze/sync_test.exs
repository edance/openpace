defmodule Squeeze.SyncTest do
  use Squeeze.DataCase

  alias Squeeze.Sync

  import Squeeze.Factory

  describe "#load_activities/1" do
    test "without credentials returns an empty array" do
      user = build(:user, %{credential: nil})
      assert Sync.load_activities(user) == []
    end
  end
end
