defmodule Squeeze.Repo.Migrations.ChangeExternalIdToString do
  use Ecto.Migration

  def up do
    alter table(:activities) do
      modify :external_id, :string
    end
  end

  def down do
    alter table(:activities) do
      modify :external_id, :integer
    end
  end
end
