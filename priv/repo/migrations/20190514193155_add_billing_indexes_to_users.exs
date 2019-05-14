defmodule Squeeze.Repo.Migrations.AddBillingIndexesToUsers do
  use Ecto.Migration

  def change do
    create index(:users, [:customer_id])
    create index(:users, [:subscription_id])
  end
end
