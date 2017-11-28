defmodule Squeeze.Repo.Migrations.AddColorToPaces do
  use Ecto.Migration

  def change do
    alter table(:paces) do
      add :color, :string
    end
  end
end
