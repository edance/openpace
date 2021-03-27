defmodule Squeeze.ExpoNotifications do
  @moduledoc """
  Provides a basic HTTP interface to allow easy communication with the Exponent Push Notification
  API, by wrapping `HTTPotion`.

  ## Examples
  Requests are made to the Exponent Push Notification API by passing in a `Map` into one
  of the `Notification` module's functions. The correct URL to the resource is inferred
  from the module name.

    ExponentServerSdk.PushNotification.push(messages)
    {:ok, %{"status" => "ok", "id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"}}

  Items are returned as instances of the given module's struct. For more
  details, see the documentation for each function.
  """

  use Tesla

  plug(Tesla.Middleware.BaseUrl, "https://exp.host/--/api/v2/push")
  plug Tesla.Middleware.Compression, format: "gzip"
  plug Tesla.Middleware.JSON

  def push_list(messages) when is_list(messages) do
    post("send", messages)
  end

  def push(message) do
    post("send", message)
  end
end
