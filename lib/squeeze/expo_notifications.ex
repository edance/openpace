defmodule Squeeze.ExpoNotifications do
  @moduledoc """
  Provides a basic HTTP interface to allow easy communication with the Exponent Push Notification
  API, by wrapping `Tesla`.

  ## Examples
  Requests are made to the Exponent Push Notification API by passing in a `Map` into one
  of the `Notification` module's functions. The correct URL to the resource is inferred
  from the module name.

  ```elixir
  ExpoNotifications.push_list(messages)
  {:ok, %{"status" => "ok", "id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"}}
  ```

  Items are returned as instances of the given module's struct. For more
  details, see the documentation for each function.
  """
  def push_list(messages) do
    provider = Application.get_env(:squeeze, :notification_provider)

    if Enum.empty?(messages) do
      {:ok, []}
    else
      provider.push_list(messages)
    end
  end

  defmodule NotificationMessage do
    @moduledoc false

    defstruct [
      :to,
      :title,
      :body
    ]

    @type t :: %__MODULE__{
            to: String.t(),
            title: String.t(),
            body: String.t()
          }
  end

  defmodule NotificationProvider do
    @moduledoc false
    @callback push_list([NotificationMessage.t()]) ::
                {:ok, [NotificationMessage.t()] | {:error, Tesla.Env.t()}}
  end

  defmodule DefaultNotificationProvider do
    @moduledoc false
    @behaviour NotificationProvider
    @impl NotificationProvider

    def push_list(messages) do
      middleware = [
        {Tesla.Middleware.BaseUrl, "https://exp.host/--/api/v2/push"},
        {Tesla.Middleware.Compression, format: "gzip"},
        Tesla.Middleware.JSON
      ]

      client = Tesla.client(middleware)
      Tesla.post(client, "send", messages)
    end
  end
end
