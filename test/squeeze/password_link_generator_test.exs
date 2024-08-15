defmodule Squeeze.PasswordLinkGeneratorTest do
  use Squeeze.DataCase

  @moduledoc false

  import Squeeze.Factory
  alias Squeeze.PasswordLinkGenerator

  describe "create_link/2" do
    setup [:create_user]

    test "generates a link for the user", %{user: user} do
      time = :erlang.system_time(:seconds)
      token = create_token(user, time)
      signature = sign_token(token)
      link = PasswordLinkGenerator.create_link(user, time)

      assert link =~ "token=#{token}"
      assert link =~ "signature=#{signature}"
      assert link =~ "/reset-password"
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
      # One day, one sec ago
      time = :erlang.system_time(:seconds) - 86_401
      link = PasswordLinkGenerator.create_link(user, time)
      %{"token" => token, "signature" => signature} = parse_query_params(link)
      assert {:error, "Token has expired"} = PasswordLinkGenerator.verify_link(token, signature)
    end

    test "with an invalid token", %{user: user} do
      link = PasswordLinkGenerator.create_link(user)
      time = :erlang.system_time(:seconds) - 5
      token = create_token(user, time)
      %{"signature" => signature} = parse_query_params(link)
      assert {:error, "Token not valid"} = PasswordLinkGenerator.verify_link(token, signature)
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
    :crypto.mac(:hmac, :sha256, secret_key(), token)
    |> Base.url_encode64()
  end

  defp secret_key do
    Application.get_env(:squeeze, Squeeze.Guardian)[:secret_key]
  end

  def parse_query_params(link) do
    %{query: query} = URI.parse(link)

    query
    |> URI.query_decoder()
    |> Map.new()
  end
end
