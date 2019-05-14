defmodule Squeeze.InvoiceFactory do
  @moduledoc false

  alias Faker.{Lorem}
  alias Squeeze.Billing.Invoice

  defmacro __using__(_opts) do
    quote do
      def invoice_factory do
        date = Faker.DateTime.forward(10)

        %Invoice{
          name: "#{DateTime.to_date(date)} Invoice",
          amount_due: 595,
          provider_id: "invoice_#{Lorem.characters(15)}",
          status: Enum.random(["pending", "paid"]),
          due_date: date,

          user: build(:user)
        }
      end
    end
  end
end
