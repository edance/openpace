defmodule Squeeze.Billing do
  @moduledoc """
  The Billing context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Squeeze.Accounts.User
  alias Squeeze.Billing.PaymentMethod
  alias Squeeze.Repo
  # alias Stripe.{Customer, Subscription}

  @payment_processor Application.get_env(:squeeze, :payment_processor)
  @plan_id "plan_EOxadIoXIhD2MO"
  @trial_period_days 30

  @doc """
  Returns the list of payment_methods.

  ## Examples

      iex> get_default_payment_method(%User{})
      %PaymentMethod{}

      iex> get_default_payment_method(%User{})
      nil

  """
  def get_default_payment_method(%User{} = user) do
    PaymentMethod
    |> by_user(user)
    |> order_by([a], [desc: a.inserted_at])
    |> limit(1)
    |> Repo.one()
  end

  def start_free_trial(%User{subscription_id: nil} = user) do
    {:ok, customer} = @payment_processor.create_customer(Map.from_struct(user))
    {:ok, subscription} = @payment_processor.create_subscription(
      customer.id,
      @plan_id,
      @trial_period_days
    )
    attrs = %{customer_id: customer.id, subscription_id: subscription.id}
    user
    |> User.payment_processor_changeset(attrs)
    |> Repo.update()
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
