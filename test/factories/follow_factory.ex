defmodule Squeeze.FollowFactory do
  @moduledoc false

  alias Squeeze.Social.Follow

  defmacro __using__(_opts) do
    quote do
      def follow_factory do
        %Follow{
          follower: build(:user),
          followee: build(:user),
          pending: false
        }
      end
    end
  end
end
