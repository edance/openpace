defmodule SqueezeWeb.Router do
  use SqueezeWeb, :router

  import Redirect
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
  end

  pipeline :live_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SqueezeWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Squeeze.LiveAuthPipeline
    plug Plug.Locale
  end

  pipeline :unauthenticated do
    plug Guardian.Plug.EnsureNotAuthenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :put_layout, {SqueezeWeb.LayoutView, :none}
    plug :put_resp_content_type, "application/json"
  end

  pipeline :api_auth do
    plug Squeeze.Api.AuthPipeline
    plug Plug.Auth
  end

  pipeline :dashboard_layout do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :xml do
    plug :accepts, ["xml"]
    plug :put_layout, {SqueezeWeb.LayoutView, :none}
    plug :put_resp_content_type, "application/xml"
  end

  pipeline :no_layout do
    plug :put_layout, {SqueezeWeb.LayoutView, :none}
  end

  # Redirects
  redirect("/docs", "/docs/index.html", :permanent, preserve_query_string: true)

  scope "/integration", SqueezeWeb do
    # Use the default browser stack
    pipe_through :browser

    get "/strava", StravaIntegrationController, :request
    get "/strava/callback", StravaIntegrationController, :callback
    post "/strava/callback", StravaIntegrationController, :callback
  end

  scope "/auth", SqueezeWeb do
    # Use the default browser stack
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end

  scope "/dashboard", SqueezeWeb do
    pipe_through [:live_browser]

    live_session :dashboard, on_mount: SqueezeWeb.LiveAuth do
      live "/overview", Dashboard.OverviewLive, :index, as: :overview

      live "/calendar", CalendarLive, :index
      live "/challenges", ChallengeLive, :index
      live "/challenges/new", Challenges.NewLive, :new, as: :challenge
      live "/challenges/:id", Challenges.ShowLive, :show, as: :challenge

      live "/activities", ActivityLive.Index, :index, as: :activity_index
      live "/activities/:slug", ActivityLive.Show, :show, as: :activity

      live "/trends", TrendsLive.Index, :index, as: :trends
      live "/trends/:year", TrendsLive.Index, :show, as: :trends

      live "/races", RaceLive.Index, :index, as: :race
      live "/races/new", RaceLive.New, :new, as: :race
      live "/races/:slug", RaceLive.Show, :show, as: :race

      live "/settings", SettingsLive, :general
      live "/settings/namer", SettingsLive, :namer
      live "/settings/personal-records", SettingsLive, :personal_records
      live "/settings/api", SettingsLive, :api

      live "/strava-bulk-upload", StravaBulkUploadLive, :index
    end
  end

  scope "/dashboard", SqueezeWeb do
    pipe_through [:browser, :dashboard_layout]

    get "/", DashboardController, :index

    get "/billing", BillingController, :portal
    get "/checkout", BillingController, :checkout

    put "/challenges/:id/join", ChallengeController, :join
  end

  scope "/webhook", SqueezeWeb do
    get "/strava", StravaWebhookController, :challenge
    post "/strava", StravaWebhookController, :webhook

    post "/stripe", StripeWebhookController, :webhook
  end

  scope "/", SqueezeWeb do
    # Redirect these users to the dashboard pages
    pipe_through [:browser, :unauthenticated]

    get "/", HomeController, :index
    get "/namer", HomeController, :namer
    post "/", HomeController, :subscribe

    get "/login", SessionController, :new
    post "/login", SessionController, :create

    get "/sign-up", UserController, :new
    post "/sign-up", UserController, :register
    put "/sign-up", UserController, :register

    get "/forgot-password", ForgotPasswordController, :show
    post "/forgot-password", ForgotPasswordController, :request

    get "/reset-password", ResetPasswordController, :show
    post "/reset-password", ResetPasswordController, :reset
    put "/reset-password", ResetPasswordController, :reset
  end

  scope "/", SqueezeWeb do
    # Use the default browser stack
    pipe_through :browser

    get "/privacy", PageController, :privacy_policy
    get "/terms", PageController, :terms
    get "/support", PageController, :support

    get "/logout", SessionController, :delete
    delete "/logout", SessionController, :delete

    get "/invite/:slug", ChallengeShareController, :show
  end

  scope "/sitemap", SqueezeWeb do
    pipe_through :xml

    get "/index.xml", SitemapController, :index
  end

  scope "/export", SqueezeWeb do
    get "/users/:slug/activities.csv", ExportController, :activities
  end

  scope "/api", SqueezeWeb.Api, as: :api do
    pipe_through :api

    post "/users/signup", UserController, :create
    post "/users/signin", UserController, :signin

    post "/google/auth", GoogleAuthController, :auth

    resources "/challenges", ChallengeController, only: [:show]
  end

  scope "/api", SqueezeWeb.Api, as: :api do
    pipe_through [:api, :api_auth]

    resources "/challenges", ChallengeController, only: [:index, :create]
    get "/challenges/:id/leaderboard", ChallengeController, :leaderboard
    get "/challenges/:id/status", ChallengeController, :status
    put "/challenges/:id/join", ChallengeController, :join

    get "/challenges/:id/activities", ChallengeActivityController, :index

    post "/strava/exchange", StravaController, :exchange_code

    resources "/push_tokens", PushTokenController, only: [:create]

    get "/segments/starred", SegmentController, :starred
    get "/segments/:id", SegmentController, :show

    put "/users/me", UserController, :update
    get "/users/me", UserController, :me
    get "/users/:slug", UserController, :show

    put "/user_prefs/me", UserPrefsController, :update

    get "/users/me/activities", ActivityController, :index

    get "/users/:slug/followers", FollowController, :followers
    get "/users/:slug/following", FollowController, :following
    post "/follow/:slug", FollowController, :follow
    delete "/unfollow/:slug", FollowController, :unfollow
  end

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end
end
