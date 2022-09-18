defmodule Squeeze.Garmin.Middleware.OAuth do
  @moduledoc false

  @behaviour Tesla.Middleware

  @config Application.compile_env(:squeeze, Squeeze.Garmin)

  alias Squeeze.OAuth1

  def call(env, next, opts) do
    creds = oauth_credentials(opts)
    method = env.method |> Atom.to_string() |> String.upcase()
    params = OAuth1.sign(method, env.url, env.query, creds)
    {header, _req_params} = OAuth1.header(params)
    env
    |> Tesla.put_headers([header])
    |> Tesla.run(next)
  end

  defp oauth_credentials(opts) do
    @config
    |> Keyword.take([:consumer_key, :consumer_secret])
    |> Keyword.merge(opts)
    |> OAuth1.credentials()
  end
end
