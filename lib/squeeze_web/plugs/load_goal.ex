defmodule SqueezeWeb.Plug.LoadGoal do
  import Plug.Conn

  alias Squeeze.Dashboard

  def init(options) do
    options
  end

  def call(conn, _) do
    user = conn.assigns.current_user
    goal = Dashboard.get_current_goal(user)
    assign(conn, :goal, goal)
  end
end
