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
    url = auth_module().authorize_url!(scope: scope, expires_in: 31_536_000)
    redirect(conn, external: url)
  end

  def callback(conn, %{"code" => code}) do
    client = auth_module().get_token!(code: code, grant_type: "authorization_code")
    credential_params = auth_module().get_credential!(client)

    cond do
      user = Accounts.get_user_by_credential(credential_params) ->
        sign_in_and_redirect(conn, user, credential_params)

      conn.assigns[:current_user] ->
        connect_and_redirect(conn, credential_params)

      true ->
        create_user_and_redirect(conn, credential_params)
    end
  end

  def auth_module do
    Application.get_env(:squeeze, :fitbit_auth, Fitbit.Auth)
  end

  def client_module do
    Application.get_env(:squeeze, :fitbit_client, Fitbit.Client)
  end

  defp connect_and_redirect(conn, credential_params) do
    user = conn.assigns.current_user

    case Accounts.create_credential(user, credential_params) do
      {:ok, credential} ->
        conn
        |> setup_integration(credential)
        |> redirect_current_user(credential_params)

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
         {:ok, credential} <- Accounts.create_credential(user, credential_params) do
      Reporter.report_new_user(user)

      conn
      |> setup_integration(credential)
      |> Auth.sign_in(user)
      |> redirect_current_user(credential_params)
    else
      _ ->
        conn
        |> put_flash(:error, "Authentication failed")
        |> redirect(to: Routes.home_path(conn, :namer))
    end
  end

  defp user_attrs(credential_params) do
    client = client_module().new(credential_params.access_token)

    case client_module().get_logged_in_user(client) do
      {:ok, user_data} ->
        parse_user_data(user_data)

      {:error, _} ->
        %{}
    end
  end

  defp parse_user_data(user_data) do
    %{
      first_name: user_data["firstName"],
      last_name: user_data["lastName"],
      avatar: user_data["avatar"],
      user_prefs: %{
        imperial: user_data["distanceUnit"] == "en_US",
        rename_activities: false,
        gender: parse_gender_str(user_data["gender"]),
        birthdate: parse_date_str(user_data["dateOfBirth"]),
        timezone: user_data["timezone"]
      }
    }
  end

  defp parse_gender_str(str) do
    case str do
      "MALE" -> :male
      "FEMALE" -> :female
      _ -> :prefer_not_to_say
    end
  end

  defp parse_date_str(date) do
    case Timex.parse(date, "{YYYY}-{0M}-{0D}") do
      {:ok, date} -> date |> Timex.to_date()
      {:error, _} -> nil
    end
  end

  defp redirect_current_user(conn, credential) do
    conn
    |> put_flash(:info, "Connected to #{credential.provider}")
    |> redirect(to: Routes.dashboard_path(conn, :index))
  end

  defp setup_integration(conn, _credential) do
    #   client = client_module().new(credential)
    #
    #   case client_module().create_subscription(client, credential.user_id) do
    #     {:ok, _} ->
    #       conn
    #
    #     {:error, reason} ->
    #       conn
    #       |> put_flash(:error, "Failed to setup subscription: #{reason}")
    #   end
    conn
  end
end
