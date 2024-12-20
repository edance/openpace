defmodule SqueezeWeb.Api.SegmentController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Accounts
  alias Squeeze.Strava.Client

  action_fallback SqueezeWeb.Api.FallbackController

  def starred(conn, params) do
    user = conn.assigns.current_user

    with {:ok, credential} <- Accounts.fetch_credential_by_provider(user, "strava"),
         {:ok, segments} <- get_strava_segments(credential, params) do
      render(conn, "starred.json", %{segments: segments})
    end
  end

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user

    with {id, ""} <- Integer.parse(id),
         {:ok, credential} <- Accounts.fetch_credential_by_provider(user, "strava"),
         {:ok, segment} <- get_strava_segment(credential, id) do
      render(conn, "segment.json", %{segment: segment})
    end
  end

  defp get_strava_segments(credential, params) do
    opts = [
      per_page: params[:per_page] || 50,
      page: params[:page] || 1
    ]

    Client.new(credential)
    |> segments_module().get_logged_in_athlete_starred_segments(opts)
  end

  defp get_strava_segment(credential, id) do
    Client.new(credential)
    |> segments_module().get_segment_by_id(id)
  end

  defp segments_module do
    Application.get_env(:squeeze, :strava_segments, Strava.Segments)
  end
end
