defmodule Squeeze.Dashboard do
  @moduledoc """
  The Dashboard context.
  """

  use OAuth2.Strategy

  import Ecto.Query, warn: false
  alias Squeeze.Repo


  @doc """
  Returns the list of activities.

  ## Examples

      iex> list_activities()
      [%Activity{}, ...]

  """
  def list_activities(user) do
    token = user.credential.token
    opts = %{beforeDate: "2017-10-01", offset: 0, sort: "desc", limit: 100}
    url = "/1/user/-/activities/list.json" <> query(opts)
    case Ueberauth.Strategy.Squeeze.OAuth.get(token, url) do
      { :ok, %OAuth2.Response{ status_code: status_code, body: res } } when status_code in 200..399 ->
        res["activities"]
      { :error, %OAuth2.Error{ reason: reason } } ->
        []
    end
  end

  @doc """
  Gets a single activity.

  Raises if the Activity does not exist.

  ## Examples

      iex> get_activity!(123)
      %Activity{}

  """
  def get_activity!(id), do: raise "TODO"

  defp query(opts) do
    string = opts
    |> Enum.map(fn {key, value} -> "#{key}=#{value}" end)
    |> Enum.join("&")

    "?" <> string
  end
end
