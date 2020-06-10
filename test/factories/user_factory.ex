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
          registered: true,
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
    end
  end
end
