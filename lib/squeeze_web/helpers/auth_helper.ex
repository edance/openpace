defmodule SqueezeWeb.Helpers.AuthHelper do
  @moduledoc """
  Helper for authentication with live views.
  Pulled from https://github.com/ueberauth/guardian_phoenix/issues/6#issuecomment-636768462
  """

  alias Squeeze.Guardian

  @token_key "guardian_default_token"

  def get_current_user(%{@token_key => token}) do
    case Guardian.resource_from_token(token) do
      {:ok, user, _claims} -> user
      _ -> nil
    end
  end
  def get_current_user(_), do: nil
end
