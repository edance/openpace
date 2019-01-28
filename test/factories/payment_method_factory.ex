defmodule Squeeze.PaymentMethodFactory do
  @moduledoc false

  alias Faker.{Address, Lorem, Name}
  alias Squeeze.Billing.PaymentMethod

  defmacro __using__(_opts) do
    quote do
      def payment_method_factory do
        company = Enum.random(["Visa", "Mastercard", "American Express"])
        owner = Name.name()

        %PaymentMethod{
          owner_name: owner,
          address_city: Address.city(),
          address_country: Address.country(),
          address_line1: Address.street_address(),
          address_line2: Address.secondary_address(),
          address_state: Address.state(),
          address_zip: Address.zip(),

          name: "#{owner}'s #{company}",
          exp_month: Enum.random(1..12),
          exp_year: Timex.today.year + Enum.random(1..6),
          last4: "1234",
          stripe_id: "card_#{Lorem.characters(15)}",
          user: build(:user)
        }
      end
    end
  end
end
