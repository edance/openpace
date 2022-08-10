defmodule Squeeze.PasswordLinkGenerator do
  @moduledoc """
  Signs and verifies text

  Pulled from: https://github.com/trenpixster/addict/blob/master/lib/addict/crypto.ex
  """

  alias Squeeze.Accounts.User

  @doc """
  """
  def create_link(%User{id: id}, time \\ :erlang.system_time(:seconds)) do
    token = Base.url_encode64("#{time},#{id}")
    signature = sign_token(token)
    "#{base_url()}/reset-password?token=#{token}&signature=#{signature}"
  end

  def verify_link(token, signature) do
    [timestamp, _] = parse_token(token)
    diff = :erlang.system_time(:seconds) - timestamp
    cond do
      diff > token_ttl() -> {:error, "Token has expired"}
      sign_token(token) == signature -> {:ok, true}
      true -> {:error, "Token not valid"}
    end
  end

  def parse_token(token) do
    token
    |> Base.url_decode64!()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp sign_token(token) do
    :crypto.mac(:hmac, :sha256, secret_key(), token)
    |> Base.url_encode64
  end

  defp secret_key do
    Application.get_env(:squeeze, Squeeze.Guardian)[:secret_key]
  end

  def token_ttl, do: 86_400

  defp base_url do
    url = Application.get_env(:squeeze, SqueezeWeb.Endpoint)[:url]
    %URI{
      scheme: url[:scheme],
      host: url[:host],
      port: url[:port]
    }
    |> URI.to_string()
  end
end
