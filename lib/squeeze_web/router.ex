defmodule SqueezeWeb.Router do
  use SqueezeWeb, :router

  alias SqueezeWeb.Plug

  pipeline :browser do
    plug :accepts, ["html"]
    plug Plug.EnsureHost
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Squeeze.AuthPipeline
    plug Plug.Auth
    plug Plug.Locale
    plug Turbolinks
  end

  pipeline :dashboard_layout do
    plug :put_layout, {SqueezeWeb.LayoutView, :dashboard}
  end

  pipeline :xml do
    plug :accepts, ["xml"]
    plug :put_layout, {SqueezeWeb.LayoutView, :none}
    plug :put_resp_content_type, "application/xml"
  end

  scope "/", SqueezeWeb do
    pipe_through :browser # Use the default browser stack

    get "/", HomeController, :index
    get "/privacy", PageController, :privacy_policy
    get "/terms", PageController, :terms

    get "/quiz", WizardController, :index
    get "/quiz/:step", WizardController, :step
    put "/quiz/:step", WizardController, :update

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete

    get "/sign-up", UserController, :new
    post "/sign-up", UserController, :register
    put "/sign-up", UserController, :register

    get "/forgot-password", ForgotPasswordController, :show
    post "/forgot-password", ForgotPasswordController, :request

    get "/reset-password", ResetPasswordController, :show
    post "/reset-password", ResetPasswordController, :reset
    put "/reset-password", ResetPasswordController, :reset

    get "/races/:state/:city/:name", RaceController, :show
  end

  scope "/integration", SqueezeWeb do
    pipe_through :browser # Use the default browser stack

    get "/:provider", IntegrationController, :request
    get "/:provider/callback", IntegrationController, :callback
    post "/:provider/callback", IntegrationController, :callback
  end

  scope "/auth", SqueezeWeb do
    pipe_through :browser # Use the default browser stack

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
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
    put "/billing/cancel", BillingController, :cancel

    resources "/payment", PaymentMethodController,
      only: [:index, :new, :create, :delete]

    resources "/activities", ActivityController

    resources "/plans", PlanController
  end

  scope "/webhook", SqueezeWeb do
    get "/strava", StravaWebhookController, :challenge
    post "/strava", StravaWebhookController, :webhook

    get "/fitbit", FitbitWebhookController, :webhook
    post "/fitbit", FitbitWebhookController, :webhook

    post "/stripe", StripeWebhookController, :webhook
  end

  scope "/sitemap", SqueezeWeb do
    pipe_through :xml

    get "/index.xml", SitemapController, :index
  end

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end
end
