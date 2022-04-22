defmodule Squeeze.UserFactory do
  @moduledoc false

  alias Faker.{Address, Internet, Name}
  alias Squeeze.Accounts.User

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        # Set all passwords to "password"
        encrypted_password = Argon2.hash_pwd_salt("password")

        %User{
          first_name: Name.first_name(),
          last_name: Name.last_name(),
          email: Internet.email(),
          encrypted_password: encrypted_password,
          city: Address.city(),
          state: Address.state_abbr(),
          avatar: "https://placekitten.com/300/300",
          country: Address.country_code(),
          registered: true,
          slug: sequence(:user_slug, &"#{&1}"),
          user_prefs: build(:user_prefs)
        }
      end

      def paid_user_factory do
        struct!(
          user_factory(),
          %{
            customer_id: "cus_12345",
            subscription_id: "sub_12345",
            subscription_status: :active
          }
        )
      end

      def with_push_token(%User{} = user) do
        insert(:push_token, user: user)
        user
      end
    end
  end
end
