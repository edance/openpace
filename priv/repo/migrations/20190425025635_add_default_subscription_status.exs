defmodule Squeeze.Repo.Migrations.AddDefaultSubscriptionStatus do
  use Ecto.Migration

  def up do
    statuses = SubscriptionStatusEnum.__enum_map__()
    alter table(:users) do
      modify :subscription_status, :integer, default: statuses[:active], null: false
    end
  end

  def down do
    alter table(:users) do
      modify :subscription_status, :integer, default: nil, null: true
    end
  end
end
