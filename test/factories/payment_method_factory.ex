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
          address_zip: Address.zip(),

          exp_month: Enum.random(1..12),
          exp_year: Timex.today.year + Enum.random(1..6),
          last4: "#{Enum.random(1000..9999)}",
          stripe_id: "card_#{Lorem.characters(15)}",
          user: build(:user)
        }
      end
    end
  end
end
