defmodule Squeeze.UserFactory do
  @moduledoc false

  alias Faker.{Address, Internet, Person}
  alias Squeeze.Accounts.User

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        # Set all passwords to "password"
        encrypted_password = Argon2.hash_pwd_salt("password")
        email = Internet.email()

        hash =
          email
          |> :erlang.md5()
          |> Base.encode16(case: :lower)

        avatar = "https://www.gravatar.com/avatar/#{hash}?s=300&d=identicon"

        %User{
          first_name: Person.first_name(),
          last_name: Person.last_name(),
          email: Internet.email(),
          encrypted_password: encrypted_password,
          city: Address.city(),
          state: Address.state_abbr(),
          avatar: avatar,
          country: Address.country_code(),
          registered: true,
          slug: sequence(:slug, &"#{Squeeze.SlugGenerator.gen_slug()}#{&1}"),
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
