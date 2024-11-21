defmodule Squeeze.Fitbit.Client do
  @moduledoc """
  Tesla-based HTTP client for interacting with the Fitbit API.
  """

  @behaviour Squeeze.Fitbit.ClientBehaviour

  use Tesla

  alias Squeeze.Accounts
  alias Squeeze.Accounts.Credential
  alias Squeeze.Fitbit.Middleware

  plug(Tesla.Middleware.BaseUrl, "https://api.fitbit.com")
  plug Tesla.Middleware.JSON

  @impl true
  def new(%Credential{} = credential) do
    new(credential.access_token,
      refresh_token: credential.refresh_token,
      token_refreshed:
        &Accounts.update_credential(
          credential,
          Map.from_struct(&1.token)
        )
    )
  end

  @impl true
  def new(access_token, opts \\ []) when is_binary(access_token) do
    Tesla.client([
      {Tesla.Middleware.Headers, [{"Authorization", "Bearer #{access_token}"}]},
      {Middleware.RefreshToken, opts}
    ])
  end

  @impl true
  def get_logged_in_user(client) do
    url = "/1/user/-/profile.json"

    case get(client, url) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        {:ok, body["user"]}

      {:ok, %Tesla.Env{status: 401}} ->
        {:error, :unauthorized}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def get_daily_activity_summary(client, date) do
    url = "/1/user/-/activities/date/#{date}.json"

    client
    |> get(url)
  end

  @impl true
  def get_activity_tcx(client, log_id) do
    url = "/1/user/-/activities/#{log_id}.tcx"

    client
    |> get(url)
  end

  @impl true
  def get_activities(client, opts \\ []) do
    today = Timex.format!(Timex.today(), "{YYYY}-{0M}-{0D}")
    opts = Keyword.merge(opts, limit: 20, beforeDate: today, offset: 0, sort: "desc")
    url = "/1/user/-/activities/list.json"

    client
    |> get(url, query: opts)
  end

  @impl true
  def create_subscription(client, user_id) do
    url = "/1/user/-/activities/apiSubscriptions/#{user_id}.json"

    case post(client, url) do
      {:ok, %Tesla.Env{status: 201}} -> {:ok, :created}
      {:ok, %Tesla.Env{status: 409}} -> {:ok, :exists}
      {:ok, %Tesla.Env{status: 401}} -> {:error, :unauthorized}
      {:error, reason} -> {:error, reason}
      _ -> {:error, :unknown}
    end
  end

  @impl true
  def set_authorization_header(%Tesla.Env{} = env, access_token) do
    %Tesla.Env{env | headers: [{"Authorization", "Bearer #{access_token}"}]}
  end
end
