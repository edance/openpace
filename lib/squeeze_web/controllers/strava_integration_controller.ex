defmodule SqueezeWeb.StravaIntegrationController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Accounts
  alias Squeeze.Reporter
  alias SqueezeWeb.Plug.Auth

  def request(conn, params) do
    redirect(conn, external: authorize_url!(conn, params))
  end

  def callback(conn, %{"code" => code} = params) do
    client = get_token!(code)
    athlete = auth_module().get_athlete!(client)
    credential_params = credential_params(client, athlete)

    cond do
      user = Accounts.get_user_by_credential(credential_params) ->
        sign_in_and_redirect(conn, client, user, params)

      conn.assigns[:current_user] ->
        connect_and_redirect(conn, client, athlete, params)

      true ->
        create_user_and_redirect(conn, client, athlete, params)
    end
  end

  defp authorize_url!(conn, params) do
    scope = "read,activity:read_all,activity:write"
    redirect_uri = Routes.strava_integration_url(conn, :callback, params)
    auth_module().authorize_url!(scope: scope, redirect_uri: redirect_uri)
  end

  defp get_token!(code) do
    auth_module().get_token!(code: code, grant_type: "authorization_code")
  end

  defp auth_module do
    Application.get_env(:squeeze, :strava_auth, Strava.Auth)
  end

  defp token_attrs(%{token: token}) do
    %{
      access_token: token.access_token,
      refresh_token: token.refresh_token
    }
  end

  defp user_attrs(client, athlete, params) do
    gender = if athlete.sex == "M", do: :male, else: :female

    attrs = %{
      first_name: athlete.firstname,
      last_name: athlete.lastname,
      avatar: athlete.profile,
      city: athlete.city,
      state: athlete.state,
      country: athlete.country,
      user_prefs: %{
        imperial: athlete.country == "United States",
        rename_activities: params["rename"] == "true",
        gender: gender
      }
    }

    attrs |> Map.merge(token_attrs(client))
  end

  defp connect_and_redirect(conn, client, athlete, params) do
    user = conn.assigns.current_user
    credential_params = credential_params(client, athlete)

    case Accounts.create_credential(user, credential_params) do
      {:ok, _credentials} ->
        redirect_user(conn, params)

      _ ->
        conn
        |> put_flash(:error, "Authentication failed")
        |> redirect(to: Routes.home_path(conn, :index))
    end
  end

  defp sign_in_and_redirect(conn, client, user, params) do
    credential = Enum.find(user.credentials, &(&1.provider == "strava"))
    {:ok, _credential} = Accounts.update_credential(credential, token_attrs(client))

    conn
    |> Auth.sign_in(user)
    |> redirect_user(params)
  end

  defp create_user_and_redirect(conn, client, athlete, params) do
    user_params = user_attrs(client, athlete, params)
    credential_params = credential_params(client, athlete)

    with {:ok, user} <- Accounts.create_user(user_params),
         {:ok, _credentials} <- Accounts.create_credential(user, credential_params) do
      Reporter.report_new_user(user)

      conn
      |> Auth.sign_in(user)
      |> redirect_user(params)
    else
      _ ->
        conn
        |> put_flash(:error, "Authentication failed")
        |> redirect(to: Routes.home_path(conn, :namer))
    end
  end

  def redirect_user(conn, params) do
    if params["rename"] do
      redirect(conn, to: Routes.settings_path(conn, :namer))
    else
      redirect(conn, to: Routes.overview_path(conn, :index, sync: true))
    end
  end

  defp credential_params(%{token: token}, athlete) do
    token
    |> Map.take([:access_token, :refresh_token])
    |> Map.merge(%{provider: "strava", uid: "#{athlete.id}"})
  end
end
