defmodule Squeeze.Accounts.PersonalRecord do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Squeeze.Accounts.PersonalRecord
  alias Squeeze.Duration

  import Squeeze.Distances, only: [distances: 0]

  @required_fields ~w(
    distance
  )a

  @optional_fields ~w(
    duration
    results_url
  )a

  embedded_schema do
    field :distance, :float
    field :duration, Duration
    field :results_url, :string
  end

  @doc false
  def changeset(%PersonalRecord{} = personal_record, attrs) do
    personal_record
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def default_distances do
    distances()
    |> Enum.map(&(%PersonalRecord{distance: &1.distance}))
  end
end
