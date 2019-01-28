defmodule Squeeze.Repo.Migrations.CreatePaymentMethods do
  use Ecto.Migration

  def change do
    create table(:payment_methods) do
      # Billing Information
      add :owner_name, :string
      add :address_city, :string
      add :address_country, :string
      add :address_line1, :string
      add :address_line2, :string
      add :address_state, :string
      add :address_zip, :string

      # Card Information
      add :name, :string
      add :stripe_id, :string
      add :last4, :string
      add :exp_month, :integer
      add :exp_year, :integer
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:payment_methods, [:user_id])
    # create unique_index(:payment_methods, :stripe_id)
  end
end
