defmodule SqueezeWeb.Api.PushTokenView do
  use SqueezeWeb, :view
  @moduledoc false

  def render("create.json", %{push_token: push_token}) do
    %{
      token: push_token.token
    }
  end
end
