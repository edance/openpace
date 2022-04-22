defmodule Squeeze.Strava.Client do
  @moduledoc """
  Loads data from strava and updates the activity
  """

  alias Squeeze.Accounts
  alias Squeeze.Accounts.{Credential, User}

  def new(%User{} = user) do
    case Accounts.fetch_credential_by_provider(user, "strava") do
      {:ok, credential} -> new(credential)
      _ -> nil
    end
  end

  def new(%Credential{provider: "strava"} = credential) do
    Strava.Client.new(credential.access_token,
      refresh_token: credential.refresh_token,
      token_refreshed: &Accounts.update_credential(credential, Map.from_struct(&1.token))
    )
  end
end
