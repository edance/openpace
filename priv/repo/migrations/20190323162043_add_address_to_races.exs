defmodule Squeeze.Repo.Migrations.AddAddressToRaces do
  use Ecto.Migration

  def change do
    alter table(:races) do
      add :address_line1, :string
      add :address_line2, :string
      add :postal_code, :string
    end
  end
end
