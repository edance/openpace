defmodule Squeeze.Repo.Migrations.ChangeUidToString do
  use Ecto.Migration

  def up do
    alter table(:credentials) do
      modify :uid, :string
    end
  end

  def down do
    alter table(:credentials) do
      modify :uid, :integer
    end
  end
end
