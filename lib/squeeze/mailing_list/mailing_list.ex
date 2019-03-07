defmodule Squeeze.MailingList do
  @moduledoc """
  The MailingList context.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Repo

  alias Squeeze.MailingList.Subscription

  @doc """
  Creates a subscription.

  ## Examples

      iex> create_subscription(%{field: value})
      {:ok, %Subscription{}}

      iex> create_subscription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription(attrs \\ %{}) do
    %Subscription{}
    |> Subscription.changeset(attrs)
    |> Repo.insert()
  end
end
