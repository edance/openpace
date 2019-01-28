defmodule Squeeze.Repo.Migrations.CreatePaymentMethods do
  use Ecto.Migration

  def change do
    create table(:payment_methods) do
      add :name, :string
      add :stripe_id, :string
      add :last4, :string
      add :exp_month, :integer
      add :exp_year, :integer
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:payment_methods, [:user_id])
  end
end
