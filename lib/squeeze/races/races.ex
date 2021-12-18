defmodule Squeeze.Races do
  @moduledoc """
  The Races context.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Repo

  alias Squeeze.Accounts.User
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
    Race
    |> Repo.get_by!(slug: slug)
    |> Repo.preload([:events, :result_summaries])
  end

  def create_race(%User{} = _user, attrs \\ %{}) do
    %Race{}
    |> Race.changeset(attrs)
    |> Repo.insert_with_slug()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking race changes.

  ## Examples

  iex> change_race(race)
  %Ecto.Changeset{source: %Race{}}

  """
  def change_race(%Race{} = race) do
    Race.changeset(race, %{})
  end
end
