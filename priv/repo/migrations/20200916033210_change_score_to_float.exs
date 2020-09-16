defmodule Squeeze.Repo.Migrations.ChangeScoreToFloat do
  use Ecto.Migration

  def up do
    alter table(:scores) do
      modify :score, :float
    end
  end

  def down do
    alter table(:scores) do
      modify :score, :integer
    end
  end
end
