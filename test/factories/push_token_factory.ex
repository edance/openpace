defmodule Squeeze.PushTokenFactory do
  @moduledoc false

  alias Squeeze.Notifications.PushToken

  defmacro __using__(_opts) do
    quote do
      def push_token_factory do
        %PushToken{
          token: sequence(:push_token, &"ExpoToken[#{&1}]"),
          user: build(:user)
        }
      end
    end
  end
end
