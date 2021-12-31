defmodule Squeeze.Repo.Migrations.DefaultToFreeSubscription do
  use Ecto.Migration

  def up do
    statuses = SubscriptionStatusEnum.__enum_map__()
    alter table(:users) do
      modify :subscription_status, :integer, default: statuses[:free], null: false
    end
  end

  def down do
    statuses = SubscriptionStatusEnum.__enum_map__()
    alter table(:users) do
      modify :subscription_status, :integer, default: statuses[:active], null: false
    end
  end
end
