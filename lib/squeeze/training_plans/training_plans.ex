defmodule Squeeze.TrainingPlans do
  @moduledoc """
  The TrainingPlans context.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Repo

  alias Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.TrainingPlans.Plan

  @doc """
  Returns the list of training_plans by user.

  ## Examples

      iex> list_training_plans(%User{})
      [%Plan{}, ...]

  """
  def list_plans(%User{} = user) do
    Plan
    |> by_user(user)
    |> Repo.all()
    |> Repo.preload(:events)
  end

  @doc """
  Gets a single plan.

  Raises `Ecto.NoResultsError` if the Plan does not exist.

  ## Examples

      iex> get_plan!(%User{}, 123)
      %Plan{}

      iex> get_plan!(%User{}, 456)
      ** (Ecto.NoResultsError)

  """
  def get_plan!(%User{} = user, id) do
    Plan
    |> by_user(user)
    |> Repo.get!(id)
  end

  @doc """
  Creates a plan for the user.

  ## Examples

      iex> create_plan(%User{}, %{field: value})
      {:ok, %Plan{}}

      iex> create_plan(%User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_plan(%User{} = user, attrs \\ %{}) do
    %Plan{}
    |> Plan.changeset(attrs)
    |> Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Updates a plan.

  ## Examples

      iex> update_plan(plan, %{field: new_value})
      {:ok, %Plan{}}

      iex> update_plan(plan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_plan(%Plan{} = plan, attrs) do
    plan
    |> Plan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Plan.

  ## Examples

      iex> delete_plan(plan)
      {:ok, %Plan{}}

      iex> delete_plan(plan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_plan(%Plan{} = plan) do
    Repo.delete(plan)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking plan changes.

  ## Examples

      iex> change_plan(plan)
      %Ecto.Changeset{source: %Plan{}}

  """
  def change_plan(%Plan{} = plan) do
    Plan.changeset(plan, %{})
  end

  @doc false
  defp by_user(query, %User{} = user) do
    from q in query, where: [user_id: ^user.id]
  end
end
