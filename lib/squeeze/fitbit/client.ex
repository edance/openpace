defmodule Squeeze.Fitbit.Client do
  @moduledoc """
  Handle Tesla connections for Fitbit.
  """

  use Tesla

  alias Squeeze.Accounts
  alias Squeeze.Accounts.Credential
  alias Squeeze.Fitbit.Middleware

  adapter(Tesla.Adapter.Hackney)

  plug(Tesla.Middleware.BaseUrl, "https://api.fitbit.com")
  plug Tesla.Middleware.JSON

  def new(%Credential{} = credential) do
    new(credential.access_token,
      refresh_token: credential.refresh_token,
      token_refreshed: &Accounts.update_credential(credential,
        Map.from_struct(&1.token))
    )
  end

  def new(access_token, opts \\ []) when is_binary(access_token) do
    Tesla.client([
      {Tesla.Middleware.Headers, [{"Authorization", "Bearer #{access_token}"}]},
      {Middleware.RefreshToken, opts}
    ])
  end

  def get_daily_activity_summary(client, date) do
    url = "/1/user/-/activities/date/#{date}.json"
    client
    |> get(url)
  end

  def get_activity_tcx(client, log_id) do
    url = "/1/user/-/activities/#{log_id}.tcx"
    client
    |> get(url)
  end

  def get_activities(client, opts \\ []) do
    today = Timex.format!(Timex.today, "{YYYY}-{0M}-{0D}")
    opts = Keyword.merge(opts, [limit: 20, beforeDate: today, offset: 0, sort: "desc"])
    url = "/1/user/-/activities/list.json"
    client
    |> get(url, query: opts)
  end

  @doc false
  def set_authorization_header(%Tesla.Env{} = env, access_token) do
    %Tesla.Env{env | headers: [{"Authorization", "Bearer #{access_token}"}]}
  end
end
