defmodule Squeeze.Repo.Migrations.AddRegisteredToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :registered, :boolean, default: false, null: false
    end
  end
end
