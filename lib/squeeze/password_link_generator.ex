defmodule Squeeze.PasswordLinkGenerator do
  @moduledoc """
  Signs and verifies text
  """
  # Pulled from:
  # https://github.com/trenpixster/addict/blob/master/lib/addict/crypto.ex

  alias Squeeze.Accounts.User

  @base_url System.get_env("HOST_URL")
  @secret_key Application.get_env(:squeeze, Squeeze.Guardian)[:secret_key]
  @token_ttl 86_400

  @doc """
  """
  def create_link(%User{id: id}, time \\ :erlang.system_time(:seconds)) do
    reset_string = Base.url_encode64("#{time},#{id}")
    signature = sign(reset_string)
    "#{@base_url}/reset-password?token=#{reset_string}&signature=#{signature}"
  end

  def verify_link(token, signature) do
    [timestamp, _] = parse_token(token)
    diff = :erlang.system_time(:seconds) - timestamp
    cond do
      diff > @token_ttl -> {:error, "Token has expired"}
      sign(token) == signature -> {:ok, true}
      true -> {:error, "Password reset token not valid."}
    end
  end

  def parse_token(token) do
    token
    |> Base.url_decode64!()
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  defp sign(plaintext) do
    :sha512
    |> :crypto.hmac(@secret_key, plaintext)
    |> Base.url_encode64
  end
end
