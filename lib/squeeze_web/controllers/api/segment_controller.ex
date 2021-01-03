defmodule SqueezeWeb.Api.SegmentController do
  use SqueezeWeb, :controller

  alias Squeeze.Accounts
  alias Squeeze.Strava.Client

  action_fallback SqueezeWeb.Api.FallbackController

  @strava_segments Application.get_env(:squeeze, :strava_segments)

  def starred(conn, params) do
    user = conn.assigns.current_user

    with {:ok, credential} <- Accounts.fetch_credential_by_provider(user, "strava"),
         {:ok, segments} <- get_strava_segments(credential, params) do

      render(conn, "starred.json", %{segments: segments})
    end
  end

  def get_strava_segments(credential, params) do
    opts = [
      per_page: params[:per_page] || 50,
      page: params[:page] || 1,
    ]
    Client.new(credential)
    |> @strava_segments.get_logged_in_athlete_starred_segments(opts)
  end
end
