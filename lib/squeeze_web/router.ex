defmodule SqueezeWeb.Router do
  use SqueezeWeb, :router

  alias SqueezeWeb.Plug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Guardian.Plug.Pipeline, module: Squeeze.Guardian, error_handler: Squeeze.AuthErrorHandler
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource, allow_blank: true
    plug Plug.Auth
    plug Turbolinks
  end

  pipeline :authorized do
    plug Plug.RequireUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :dashboard_layout do
    plug Plug.LoadGoal
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
    get "/calendar", CalendarController, :index
    resources "/activities", ActivityController, only: [:index, :show]
    resources "/events", EventController
    resources "/goals", GoalController
    resources "/paces", PaceController
  end

  # Other scopes may use custom stacks.
  scope "/api", SqueezeWeb, as: :api do
    pipe_through :api
  end
end
