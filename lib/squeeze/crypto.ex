defmodule Squeeze.Crypto do
  @moduledoc """
  Signs and verifies text
  """
  # Pulled from:
  # https://github.com/trenpixster/addict/blob/master/lib/addict/crypto.ex

  @secret_key Application.get_env(:squeeze, Squeeze.Guardian)[:secret_key]

  @doc """
  Sign `plaintext`
  """
  def sign(plaintext) do
    :sha512
    |> :crypto.hmac(@secret_key, plaintext)
    |> Base.url_encode64
  end

  @doc """
  Verify `plaintext` is signed with a key
  """
  def verify(plaintext, signature) do
    base_signature = sign(plaintext)
    do_verify(base_signature == signature)
  end

  defp do_verify(true) do
    {:ok, true}
  end

  defp do_verify(false) do
    {:error, "Password reset token not valid."}
  end
end
