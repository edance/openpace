defmodule SqueezeWeb.FitbitIntegrationController do
  use SqueezeWeb, :controller

  @moduledoc """
  Controller for Fitbit authentication integration.
  """

  alias Squeeze.Accounts
  alias Squeeze.Fitbit
  alias Squeeze.Reporter
  alias SqueezeWeb.Plug.Auth

  def request(conn, _) do
    scope = "activity heartrate profile weight location"
    url = Fitbit.Auth.authorize_url!(scope: scope, expires_in: 31_536_000)
    redirect(conn, external: url)
  end

  def callback(conn, %{"code" => code}) do
    client = Fitbit.Auth.get_token!(code: code, grant_type: "authorization_code")
    credential_params = Fitbit.Auth.get_credential!(client)

    cond do
      user = Accounts.get_user_by_credential(credential_params) ->
        sign_in_and_redirect(conn, user, credential_params)

      conn.assigns[:current_user] ->
        connect_and_redirect(conn, credential_params)

      true ->
        create_user_and_redirect(conn, credential_params)
    end
  end

  defp connect_and_redirect(conn, credential_params) do
    user = conn.assigns.current_user

    case Accounts.create_credential(user, credential_params) do
      {:ok, _credentials} ->
        setup_integration(conn, user)
        redirect_current_user(conn, credential_params)

      _ ->
        conn
        |> put_flash(:error, "Authentication failed")
        |> redirect(to: Routes.home_path(conn, :index))
    end
  end

  defp sign_in_and_redirect(conn, user, credential_params) do
    credential = Enum.find(user.credentials, &(&1.provider == "fitbit"))
    {:ok, _credential} = Accounts.update_credential(credential, credential_params)

    conn
    |> Auth.sign_in(user)
    |> redirect_current_user(credential_params)
  end

  defp create_user_and_redirect(conn, credential_params) do
    user_params = user_attrs(credential_params)

    with {:ok, user} <- Accounts.create_user(user_params),
         {:ok, _credentials} <- Accounts.create_credential(user, credential_params) do
      Reporter.report_new_user(user)
      setup_integration(conn, user)

      conn
      |> Auth.sign_in(user)
      |> redirect_current_user(credential_params)
    else
      _ ->
        conn
        |> put_flash(:error, "Authentication failed")
        |> redirect(to: Routes.home_path(conn, :namer))
    end
  end

  defp user_attrs(_credential_params) do
    %{
      user_prefs: %{
        imperial: false,
        rename_activities: false,
        gender: :prefer_not_to_say
      }
    }
  end

  defp redirect_current_user(conn, credential) do
    load_history(credential)

    conn
    |> put_flash(:info, "Connected to #{credential.provider}")
    |> redirect(to: Routes.dashboard_path(conn, :index))
  end

  defp setup_integration(conn, client) do
    user = conn.assigns.current_user
    url = "/1/user/-/activities/apiSubscriptions/#{user.id}.json"
    Fitbit.Client.post!(client, url)
  end

  def load_history(%{provider: "fitbit", uid: id}) do
    credential = Accounts.get_credential("fitbit", id)
    Task.start(fn -> Squeeze.Fitbit.HistoryLoader.load_recent(credential) end)
  end
end
