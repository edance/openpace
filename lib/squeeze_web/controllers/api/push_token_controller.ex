defmodule SqueezeWeb.Api.PushTokenController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Notifications

  action_fallback SqueezeWeb.Api.FallbackController

  def create(conn, %{"token" => token}) do
    user = conn.assigns.current_user
    with {:ok, push_token} <- Notifications.create_push_token(user, token) do
      conn
      |> put_status(:created)
      |> render("create.json", %{push_token: push_token})
    end
  end
end
