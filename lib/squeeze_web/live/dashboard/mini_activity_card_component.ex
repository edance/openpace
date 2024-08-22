defmodule SqueezeWeb.Dashboard.MiniActivityCardComponent do
  use SqueezeWeb, :live_component
  @moduledoc false

  def id(%{activity: activity}), do: "activity-#{activity.id}"
end
