defmodule Squeeze.Repo.Migrations.AddDefaultFieldsToActivities do
  use Ecto.Migration

  def up do
    alter table(:activities) do
      modify :distance, :float, default: 0.0, null: false
      modify :duration, :integer, default: 0, null: false
    end
  end

  def down do
    alter table(:activities) do
      modify :distance, :float, default: nil, null: true
      modify :duration, :integer, default: nil, null: true
    end
  end
end
