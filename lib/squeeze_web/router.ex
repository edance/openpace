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

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :dashboard_layout do
    plug :put_layout, {SqueezeWeb.LayoutView, :dashboard}
  end

  scope "/", SqueezeWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/quiz", WizardController, :index
    get "/quiz/:step", WizardController, :step
    put "/quiz/:step", WizardController, :update

    get "/login", AuthController, :login
  end

  scope "/auth", SqueezeWeb do
    pipe_through :browser # Use the default browser stack

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete
  end

  scope "/dashboard", SqueezeWeb do
    pipe_through [:browser, :dashboard_layout]

    get "/", DashboardController, :index

    get "/profile", ProfileController, :show

    get "/sync", SyncController, :sync

    resources "/activities", ActivityController, only: [:index, :show]

    get "/plan", PlanController, :index
    get "/plan/:step", PlanController, :step
    post "/plan/:step", PlanController, :update
    get "/plan/weeks/:week", PlanController, :new
    post "/plan/weeks/:week", PlanController, :create
  end

  # Other scopes may use custom stacks.
  scope "/api", SqueezeWeb, as: :api do
    pipe_through :api
  end

  scope "/webhook", SqueezeWeb do
    get "/strava", StravaWebhookController, :challenge
    post "/strava", StravaWebhookController, :webhook
  end
end
