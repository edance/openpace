defmodule Squeeze.Repo.Migrations.AddPaymentProcessorFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :customer_id, :string
      add :subscription_id, :string
    end
  end
end
