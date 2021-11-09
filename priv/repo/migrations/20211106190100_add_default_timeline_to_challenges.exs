defmodule Squeeze.Repo.Migrations.AddDefaultTimelineToChallenges do
  use Ecto.Migration

  def up do
    statuses = TimelineEnum.__enum_map__()
    alter table(:challenges) do
      modify :timeline, :integer, default: statuses[:custom], null: false
    end
  end

  def down do
    alter table(:users) do
      modify :timeline, :integer, default: nil, null: true
    end
  end
end
