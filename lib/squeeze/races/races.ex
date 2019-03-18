defmodule Squeeze.Races do
  @moduledoc """
  The Races context.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Repo

  alias Squeeze.Races.Race

  @doc """
  Gets a single race.

  Raises `Ecto.NoResultsError` if the Race does not exist.

  ## Examples

      iex> get_race!("boston-marathon")
      %Race{}

      iex> get_race!("fake-marathon")
      ** (Ecto.NoResultsError)

  """
  def get_race!(slug) do
    Repo.get_by!(Race, slug: slug)
  end
end
