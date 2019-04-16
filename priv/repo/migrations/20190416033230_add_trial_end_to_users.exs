defmodule Squeeze.Repo.Migrations.AddTrialEndToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :trial_end, :utc_datetime
      add :subscription_status, :integer
    end
  end
end
