defmodule Squeeze.Repo.Migrations.AddAmountToScores do
  use Ecto.Migration

  def change do
    alter table(:scores) do
      add :amount, :float, default: 0
    end
  end
end
