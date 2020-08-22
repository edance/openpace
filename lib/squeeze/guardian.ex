defmodule Squeeze.Guardian do
  @moduledoc """
  This module handles fetching the user from the session with guardian.
  """

  use Guardian, otp_app: :squeeze

  alias Squeeze.Accounts
  alias Squeeze.Accounts.User

  def subject_for_token(resource, _claims) do
    # You can use any value for the subject of your token but
    # it should be useful in retrieving the resource later, see
    # how it being used on `resource_from_claims/1` function.
    # A unique `id` is a good subject, a non-unique email address
    # is a poor subject.
    sub = to_string(resource.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    # Here we'll look up our resource from the claims, the subject can be
    # found in the `"sub"` key. In `above subject_for_token/2` we returned
    # the resource id so here we'll rely on that to look it up.
    id = claims["sub"]
    resource = Accounts.get_user!(id)
    {:ok,  resource}
  end

  def authenticate(email, password) do
    with {:ok, user} <- Accounts.get_by_email(email),
         {:ok, user} <- check_password(user, password) do
      create_token(user)
    end
  end

  defp check_password(%User{encrypted_password: nil}, _) do
    {:error, :unauthorized}
  end
  defp check_password(%User{} = user, password) do
    case Argon2.check_pass(user, password) do
      {:ok, user} -> {:ok, user}
      _ -> {:error, :unauthorized}
    end
  end

  defp create_token(user) do
    {:ok, token, _claims} = encode_and_sign(user)
    {:ok, user, token}
  end
end
