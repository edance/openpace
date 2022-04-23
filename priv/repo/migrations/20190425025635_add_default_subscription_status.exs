defmodule Squeeze.Repo.Migrations.AddDefaultSubscriptionStatus do
  use Ecto.Migration

  alias Squeeze.Accounts.User

  def up do
    statuses = Ecto.Enum.mappings(User, :subscription_status)
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
