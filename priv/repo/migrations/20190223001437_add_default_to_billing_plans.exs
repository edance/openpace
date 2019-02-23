defmodule Squeeze.Repo.Migrations.AddDefaultToBillingPlans do
  use Ecto.Migration

  def change do
    alter table(:billing_plans) do
      add :default, :boolean, default: false, null: false
    end
  end
end
