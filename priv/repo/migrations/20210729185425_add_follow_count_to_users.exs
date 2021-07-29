defmodule Squeeze.Repo.Migrations.AddFollowCountToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :follower_count, :integer, default: 0, null: false
      add :following_count, :integer, default: 0, null: false
    end
  end
end
