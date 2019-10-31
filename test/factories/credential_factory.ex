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

      def garmin_credential_factory do
        struct!(
          credential_factory(),
          %{
            provider: "garmin",
            access_token: nil,
            refresh_token: nil,
            token: "abcdefg",
            token_secret: "abcdefg"
          }
        )
      end
    end
  end
end
