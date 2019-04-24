defmodule Squeeze.Repo.Migrations.CreateBillingInvoices do
  use Ecto.Migration

  def change do
    create table(:billing_invoices) do
      add :name, :string
      add :amount_due, :integer
      add :status, :string
      add :due_date, :utc_datetime
      add :provider_id, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:billing_invoices, [:provider_id])
  end
end
