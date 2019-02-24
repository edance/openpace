defmodule Squeeze.Logger do
  @moduledoc """
  The Logger context.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Repo

  alias Squeeze.Logger.WebhookEvent

  @doc """
  Creates a webhook_event.

  ## Examples

      iex> log_webhook_event(%{field: value})
      {:ok, %WebhookEvent{}}

      iex> log_webhook_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def log_webhook_event(attrs \\ %{}) do
    %WebhookEvent{}
    |> WebhookEvent.changeset(attrs)
    |> Repo.insert()
  end
end
