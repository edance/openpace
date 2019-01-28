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
    plug Plug.Locale
    plug Turbolinks
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
    get "/calendar", CalendarController, :index
    get "/calendar/:type", CalendarController, :show

    get "/overview", OverviewController, :index

    get "/profile", ProfileController, :edit
    put "/profile", ProfileController, :update

    get "/billing", BillingController, :index

    resources "/payment_methods", PaymentMethodController, only: [:new, :create]

    resources "/activities", ActivityController, only: [:index, :show]

    resources "/plans", PlanController
  end

  scope "/webhook", SqueezeWeb do
    get "/strava", StravaWebhookController, :challenge
    post "/strava", StravaWebhookController, :webhook

    post "/stripe", StripeWebhookController, :webhook
  end
end
