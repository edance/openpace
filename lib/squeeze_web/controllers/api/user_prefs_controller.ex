defmodule SqueezeWeb.Api.UserPrefsController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Accounts

  action_fallback SqueezeWeb.Api.FallbackController

  def update(conn, %{"user_prefs" => params}) do
    user = conn.assigns.current_user

    with {:ok, _} <- Accounts.update_user_prefs(user.user_prefs, params) do
      send_resp(conn, :no_content, "")
    end
  end
end
