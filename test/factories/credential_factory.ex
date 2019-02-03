defmodule Squeeze.CredentialFactory do
  @moduledoc false

  alias Squeeze.Accounts.Credential

  defmacro __using__(_opts) do
    quote do
      def credential_factory do
        %Credential{
          provider: "strava",
          access_token: "abcdefg",
          refresh_token: "abcdefg",
          uid: sequence(:uid, &("#{&1}")),
          user: build(:user)
        }
      end
    end
  end
end
