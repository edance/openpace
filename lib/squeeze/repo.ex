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
  def insert_with_slug(%Ecto.Changeset{} = changeset, opts \\ []) do
    slug = Keyword.get(opts, :slug, SlugGenerator.gen_slug())

    case put_slug_and_insert(changeset, slug) do
      {:error, %Ecto.Changeset{} = changeset} ->
        if changeset.errors[:slug] do
          put_slug_and_insert(changeset, slug <> SlugGenerator.gen_slug(1))
        else
          {:error, changeset}
        end

      resp ->
        resp
    end
  end

  defp put_slug_and_insert(%Ecto.Changeset{} = changeset, slug) do
    changeset
    |> remove_slug_error()
    |> Changeset.put_change(:slug, slug)
    |> Changeset.unique_constraint(:slug)
    |> insert()
  end

  defp remove_slug_error(%Ecto.Changeset{errors: errors} = changeset) do
    errors = Enum.reject(errors, fn {field, _} -> field == :slug end)
    %{changeset | errors: errors, valid?: errors == []}
  end

  @doc """
  Similar to insert_with_slug but adds it to an existing changeset using
  Repo.update. If there is a collision, we update the slug.
  """
  def add_slug_to_existing(%Ecto.Changeset{} = changeset) do
    slug = SlugGenerator.gen_slug()

    case update_with_slug(changeset, slug) do
      {:error, %Ecto.Changeset{} = changeset} ->
        if changeset.errors[:slug] do
          update_with_slug(changeset, slug <> SlugGenerator.gen_slug(1))
        else
          {:error, changeset}
        end

      resp ->
        resp
    end
  end

  defp update_with_slug(%Ecto.Changeset{} = changeset, slug) do
    changeset
    |> remove_slug_error()
    |> Changeset.put_change(:slug, slug)
    |> Changeset.unique_constraint(:slug)
    |> update()
  end
end
