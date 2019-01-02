defmodule Squeeze.UserFactory do
  @moduledoc false

  alias Faker.{Address, Internet, Name}
  alias Squeeze.Accounts.User

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %User{
          first_name: Name.first_name(),
          last_name: Name.last_name(),
          email: Internet.email(),
          city: Address.city(),
          state: Address.state_abbr(),
          country: Address.country_code(),
          user_prefs: build(:user_prefs)
        }
      end

      def guest_user_factory do
        struct!(
          user_factory(),
          %{
            credential: nil,
            user_prefs: %{}
          }
        )
      end

      def with_credential(%User{} = user) do
        credential = insert(:credential, user: user)
        %{user | credential: credential}
      end
    end
  end
end
