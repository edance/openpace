defmodule SqueezeWeb.TrendsLive.Index do
  use SqueezeWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
