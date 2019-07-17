defmodule Squeeze.Repo.Migrations.AddTypeToTrainingEvents do
  use Ecto.Migration

  def change do
    alter table(:training_events) do
      add :type, :string
    end
  end
end
