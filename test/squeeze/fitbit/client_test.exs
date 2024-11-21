defmodule Squeeze.Fitbit.ClientTest do
  use Squeeze.DataCase

  import Tesla.Mock

  alias Squeeze.Fitbit.Client

  # import Mox
  import Squeeze.Factory

  # alias Squeeze.Strava.ActivityLoader
  # alias Squeeze.TimeHelper

  describe "#new" do
  end

  describe "#get_daily_activity_summary/2" do
    setup do
      mock fn
        %{method: :get, url: "https://api.fitbit.com/1/user/-/activities/date/2018-01-01.json"} ->
          %Tesla.Env{status: 200}
      end

      :ok
    end

    test "hits the correct url" do
      credential = insert(:credential, provider: "fitbit")
      client = Client.new(credential)
      assert {:ok, env} = Client.get_daily_activity_summary(client, "2018-01-01")
      assert env.status == 200
    end
  end

  describe "#get_activity_tcx/2" do
    setup do
      mock fn
        %{method: :get, url: "https://api.fitbit.com/1/user/-/activities/123456789.tcx"} ->
          %Tesla.Env{status: 200}
      end

      :ok
    end

    test "hits the correct url" do
      credential = insert(:credential, provider: "fitbit")
      client = Client.new(credential)
      assert {:ok, env} = Client.get_activity_tcx(client, "123456789")
      assert env.status == 200
    end
  end

  describe "#get_activities/2" do
    setup do
      mock fn
        %{method: :get, url: "https://api.fitbit.com/1/user/-/activities/list.json"} ->
          %Tesla.Env{status: 200}
      end

      :ok
    end

    test "hits the correct url" do
      credential = insert(:credential, provider: "fitbit")
      client = Client.new(credential)
      assert {:ok, env} = Client.get_activities(client)
      assert env.status == 200
    end
  end
end
