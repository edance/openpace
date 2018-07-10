defmodule SqueezeWeb.Router do
  use SqueezeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Guardian.Plug.Pipeline, module: Squeeze.Guardian, error_handler: Squeeze.AuthErrorHandler
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource, allow_blank: true
    plug Turbolinks
    plug :set_user
  end

  pipeline :authorized do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :dashboard_layout do
    plug :set_goal
    plug :put_layout, {SqueezeWeb.LayoutView, :dashboard}
  end

  scope "/", SqueezeWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/auth", SqueezeWeb do
    pipe_through :browser # Use the default browser stack

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  scope "/dashboard", SqueezeWeb do
    pipe_through [:browser, :authorized, :dashboard_layout]

    get "/", DashboardController, :index
    resources "/activities", ActivityController, only: [:index, :show]
    resources "/events", EventController
    resources "/goals", GoalController
    resources "/paces", PaceController
  end

  # Other scopes may use custom stacks.
  scope "/api", SqueezeWeb, as: :api do
    pipe_through :api
  end

  defp set_user(conn, _) do
    case Squeeze.Guardian.Plug.current_resource(conn) do
      nil -> conn
      user -> assign(conn, :current_user, user)
    end
  end

  defp set_goal(conn, _) do
    user = conn.assigns.current_user
    goal = Squeeze.Dashboard.get_current_goal(user)
    assign(conn, :goal, goal)
  end
end
