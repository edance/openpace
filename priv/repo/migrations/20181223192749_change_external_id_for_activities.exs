defmodule Squeeze.Repo.Migrations.ChangeExternalIdForActivities do
  use Ecto.Migration

  def up do
    alter table(:activities) do
      modify :external_id, :integer, default: nil, null: true
    end
  end

  def down do
    alter table(:activities) do
      modify :external_id, :integer, null: false
    end
  end
end
