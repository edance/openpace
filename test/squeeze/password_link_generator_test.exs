defmodule Squeeze.PasswordLinkGeneratorTest do
  use Squeeze.DataCase

  @moduledoc false

  import Squeeze.Factory
  alias Squeeze.PasswordLinkGenerator

  @secret_key Application.get_env(:squeeze, Squeeze.Guardian)[:secret_key]

  describe "create_link/2" do
    setup [:create_user]

    test "generates a link for the user", %{user: user} do
      time = :erlang.system_time(:seconds)
      token = create_token(user, time)
      signature = sign_token(token)
      link = "/reset-password?token=#{token}&signature=#{signature}"

      assert PasswordLinkGenerator.create_link(user, time) == link
    end
  end

  describe "verify_link/2" do
    setup [:create_user]

    test "with a valid token", %{user: user} do
      link = PasswordLinkGenerator.create_link(user)
      %{"token" => token, "signature" => signature} = parse_query_params(link)
      assert {:ok, true} = PasswordLinkGenerator.verify_link(token, signature)
    end

    test "with an expired token", %{user: user} do
      time = :erlang.system_time(:seconds) - 86_401 # One day, one sec ago
      link = PasswordLinkGenerator.create_link(user, time)
      %{"token" => token, "signature" => signature} = parse_query_params(link)
      assert {:error, "Token has expired"} =
        PasswordLinkGenerator.verify_link(token, signature)
    end

    test "with an invalid token", %{user: user} do
      link = PasswordLinkGenerator.create_link(user)
      time = :erlang.system_time(:seconds) - 5
      token = create_token(user, time)
      %{"signature" => signature} = parse_query_params(link)
      assert {:error, "Token not valid"} =
        PasswordLinkGenerator.verify_link(token, signature)
    end
  end

  describe "parse_token/1" do
    setup [:create_user]

    test "returns timestamp and user_id", %{user: user} do
      time = :erlang.system_time(:seconds)
      token = create_token(user, time)
      assert PasswordLinkGenerator.parse_token(token) == [time, user.id]
    end
  end

  defp create_user(_) do
    {:ok, user: insert(:user)}
  end

  defp create_token(user, time) do
    Base.url_encode64("#{time},#{user.id}")
  end

  defp sign_token(token) do
    :sha512
    |> :crypto.hmac(@secret_key, token)
    |> Base.url_encode64
  end

  def parse_query_params(link) do
    %{query: query} = URI.parse(link)
    query
    |> URI.query_decoder()
    |> Map.new()
  end
end
