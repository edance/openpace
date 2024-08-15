defmodule Squeeze.Repo.Migrations.DefaultToFreeSubscription do
  use Ecto.Migration

  alias Squeeze.Accounts.User

  def up do
    statuses = Ecto.Enum.mappings(User, :subscription_status)

    alter table(:users) do
      modify :subscription_status, :integer, default: statuses[:free], null: false
    end
  end

  def down do
    statuses = Ecto.Enum.mappings(User, :subscription_status)

    alter table(:users) do
      modify :subscription_status, :integer, default: statuses[:active], null: false
    end
  end
end
