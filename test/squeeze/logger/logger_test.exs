defmodule Squeeze.LoggerTest do
  use Squeeze.DataCase

  alias Squeeze.Logger

  describe "webhook_events" do
    alias Squeeze.Logger.WebhookEvent

    test "log_webhook_event/1 creates a webhook_event" do
      attrs = %{body: "body", provider: "stripe", provider_id: "event_123456789"}
      assert {:ok, %WebhookEvent{} = webhook_event} = Logger.log_webhook_event(attrs)
      assert webhook_event.body == "body"
      assert webhook_event.provider == "stripe"
      assert webhook_event.provider_id == "event_123456789"
    end
  end
end
