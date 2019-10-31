defmodule Squeeze.Garmin.HistoryLoaderTest do
  use Squeeze.DataCase

  import Squeeze.Factory
  import Tesla.Mock

  alias Squeeze.Garmin.HistoryLoader

  describe "load_recent/1" do
    setup [:setup_mocks]

    test 'sends a GET request to garmin backfill' do
      credential = insert(:garmin_credential)
      assert {:ok, %Tesla.Env{status: 202}} = HistoryLoader.load_recent(credential)
    end
  end

  defp setup_mocks(_) do
    mock fn(%{method: :get, url: url}) ->
      if String.contains?(url, "/wellness-api/rest/backfill/activities") do
        %Tesla.Env{status: 202}
      else
        %Tesla.Env{status: 400}
      end
    end

    {:ok, []}
  end
end
