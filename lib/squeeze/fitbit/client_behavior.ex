defmodule Squeeze.Fitbit.ClientBehaviour do
  @moduledoc """
  Behaviour module defining callbacks for Fitbit API client operations.
  """

  alias Squeeze.Accounts.Credential
  alias Tesla.Env

  @type client :: Tesla.Client.t()
  @type date :: String.t()
  @type log_id :: String.t()
  @type user_id :: String.t()
  @type access_token :: String.t()
  @type opts :: keyword()
  @type user_data :: map()
  @type activity_data :: map()
  @type subscription_result ::
          {:ok, :created} | {:ok, :exists} | {:error, :unauthorized | :unknown | any()}

  @doc """
  Creates a new Tesla client from a Credential struct
  """
  @callback new(Credential.t()) :: client()

  @doc """
  Creates a new Tesla client from an access token and options
  """
  @callback new(access_token(), opts()) :: client()

  @doc """
  Gets the logged in user's profile information
  """
  @callback get_logged_in_user(client()) :: {:ok, user_data()} | {:error, :unauthorized | any()}

  @doc """
  Gets daily activity summary for a specific date
  """
  @callback get_daily_activity_summary(client(), date()) :: {:ok, Env.t()} | {:error, any()}

  @doc """
  Gets TCX data for a specific activity
  """
  @callback get_activity_tcx(client(), log_id()) :: {:ok, Env.t()} | {:error, any()}

  @doc """
  Gets list of activities with optional parameters
  """
  @callback get_activities(client(), opts()) :: {:ok, Env.t()} | {:error, any()}

  @doc """
  Creates a subscription for a user's activities
  """
  @callback create_subscription(client(), user_id()) :: subscription_result()

  @doc """
  Sets the authorization header with a new access token
  """
  @callback set_authorization_header(Env.t(), access_token()) :: Env.t()
end
