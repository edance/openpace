defmodule Squeeze.Repo.Migrations.AddRegistrationUrlToRaces do
  use Ecto.Migration

  def change do
    alter table(:races) do
      add :registration_url, :string
    end
  end
end
