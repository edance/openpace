defmodule Squeeze.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :squeeze,
    adapter: Ecto.Adapters.Postgres

  alias Ecto.Changeset
  alias Squeeze.SlugGenerator

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  @doc """
  Repo.insert but with a unique identifier of a slug.
  By default, we will try this twice and then fail if there is a collision.
  """
  def insert_with_slug(%Ecto.Changeset{} = changeset) do
    case insert_with_slug(changeset, SlugGenerator.gen_slug()) do
      {:error, %Ecto.Changeset{} = changeset} ->
        if changeset.errors[:slug] do # try again if the slug has a collision
          insert_with_slug(changeset, SlugGenerator.gen_slug())
        else
          {:error, changeset}
        end
      resp -> resp
    end
  end

  defp insert_with_slug(%Ecto.Changeset{} = changeset, slug) do
    changeset
    |> Changeset.put_change(:slug, slug)
    |> insert()
  end
end
