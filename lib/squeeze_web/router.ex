defmodule SqueezeWeb.Router do
  use SqueezeWeb, :router

  alias SqueezeWeb.Plug

  pipeline :browser do
    plug :accepts, ["html"]
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
    plug Plug.RequireRegistered
    plug :put_layout, {SqueezeWeb.LayoutView, :dashboard}
  end

  pipeline :xml do
    plug :accepts, ["xml"]
    plug :put_layout, {SqueezeWeb.LayoutView, :none}
    plug :put_resp_content_type, "application/xml"
  end

  scope "/integration", SqueezeWeb do
    # Use the default browser stack
    pipe_through :browser

    get "/:provider", IntegrationController, :request
    get "/:provider/callback", IntegrationController, :callback
    post "/:provider/callback", IntegrationController, :callback
  end

  scope "/auth", SqueezeWeb do
    # Use the default browser stack
    pipe_through :browser

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

    resources "/payment", PaymentMethodController, only: [:index, :new, :create, :delete]

    resources "/activities", ActivityController do
      patch "/mark-complete", ActivityController, :mark_complete, as: :mark_complete
    end

    resources "/plans", PlanController
  end

  scope "/webhook", SqueezeWeb do
    get "/strava", StravaWebhookController, :challenge
    post "/strava", StravaWebhookController, :webhook

    get "/fitbit", FitbitWebhookController, :webhook
    post "/fitbit", FitbitWebhookController, :webhook

    post "/stripe", StripeWebhookController, :webhook

    get "/garmin", GarminWebhookController, :webhook
    post "/garmin", GarminWebhookController, :webhook
  end

  scope "/", SqueezeWeb do
    # Use the default browser stack
    pipe_through :browser

    get "/", HomeController, :index
    post "/", HomeController, :subscribe

    get "/onboard", OnboardController, :index
    put "/onboard", OnboardController, :update

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
  end

  scope "/races", SqueezeWeb do
    pipe_through :browser

    get "/", SearchController, :index
    get "/:region", RegionSearchController, :index
    get "/:region/:slug", RaceController, :show
    post "/:region/:slug", RaceController, :subscribe
  end

  scope "/sitemap", SqueezeWeb do
    pipe_through :xml

    get "/index.xml", SitemapController, :index
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end
end
