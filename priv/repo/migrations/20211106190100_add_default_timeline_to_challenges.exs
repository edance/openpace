defmodule Squeeze.Repo.Migrations.AddDefaultTimelineToChallenges do
  use Ecto.Migration

  alias Squeeze.Challenges.Challenge

  def up do
    statuses = Ecto.Enum.mappings(Challenge, :timeline)
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
