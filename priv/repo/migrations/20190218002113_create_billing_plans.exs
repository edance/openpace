defmodule Squeeze.Repo.Migrations.CreateBillingPlans do
  use Ecto.Migration

  def change do
    create table(:billing_plans) do
      add :name, :string
      add :amount, :integer
      add :provider_id, :string
      add :interval, :string

      timestamps()
    end

    create index(:billing_plans, [:provider_id])
  end
end
