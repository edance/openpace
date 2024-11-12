defmodule Squeeze.Garmin.Client do
  @moduledoc false

  use Tesla

  alias Squeeze.Accounts.Credential
  alias Squeeze.Garmin.Middleware

  plug Tesla.Middleware.JSON

  def new(%Credential{token: token, token_secret: token_secret}) do
    new(token: token, token_secret: token_secret)
  end

  def new(opts) when is_list(opts) do
    Tesla.client([
      {Middleware.OAuth, opts}
    ])
  end

  def new, do: new([])
end
