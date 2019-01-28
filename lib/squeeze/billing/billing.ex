defmodule Squeeze.Billing do
  @moduledoc """
  The Billing context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Squeeze.Repo
  alias Squeeze.Accounts.User
  alias Squeeze.Billing.PaymentMethod

  @doc """
  Returns the list of payment_methods.

  ## Examples

      iex> list_payment_methods(%User{})
      [%PaymentMethod{}, ...]

  """
  def list_payment_methods(%User{} = user) do
    PaymentMethod
    |> by_user(user)
    |> Repo.all()
  end

  @doc """
  Gets a single payment_method.

  Raises `Ecto.NoResultsError` if the Payment method does not exist.

  ## Examples

  iex> get_payment_method!(%User{}, 123)
  %PaymentMethod{}

  iex> get_payment_method!(%User{}, 456)
  ** (Ecto.NoResultsError)

  """
  def get_payment_method!(%User{} = user, id) do
    PaymentMethod
    |> by_user(user)
    |> Repo.get!(id)
  end

  @doc """
  Creates a payment_method.

  ## Examples

      iex> create_payment_method(%User{}, %{field: value})
      {:ok, %PaymentMethod{}}

      iex> create_payment_method(%User{}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_payment_method(%User{} = user, attrs \\ %{}) do
    %PaymentMethod{}
    |> PaymentMethod.changeset(attrs)
    |> Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Updates a payment_method.

  ## Examples

      iex> update_payment_method(payment_method, %{field: new_value})
      {:ok, %PaymentMethod{}}

      iex> update_payment_method(payment_method, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_payment_method(%PaymentMethod{} = payment_method, attrs) do
    payment_method
    |> PaymentMethod.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PaymentMethod.

  ## Examples

      iex> delete_payment_method(payment_method)
      {:ok, %PaymentMethod{}}

      iex> delete_payment_method(payment_method)
      {:error, %Ecto.Changeset{}}

  """
  def delete_payment_method(%PaymentMethod{} = payment_method) do
    Repo.delete(payment_method)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking payment_method changes.

  ## Examples

      iex> change_payment_method(payment_method)
      %Ecto.Changeset{source: %PaymentMethod{}}

  """
  def change_payment_method(%PaymentMethod{} = payment_method) do
    PaymentMethod.changeset(payment_method, %{})
  end

  defp by_user(query, %User{} = user) do
    from q in query, where: [user_id: ^user.id]
  end
end
