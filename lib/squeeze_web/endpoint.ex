defmodule SqueezeWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :squeeze

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_squeeze_key",
    signing_salt: "6ufZxrtq"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :squeeze,
    gzip: true,
    only: SqueezeWeb.static_paths(),
    content_types: %{"apple-app-site-association" => "application/json"}

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  # https://hexdocs.pm/plug/Plug.Parsers.html#module-custom-body-reader
  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["text/*"],
    body_reader: {CacheBodyReader, :read_body, []},
    json_decoder: Jason

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session, @session_options

  plug CORSPlug, origin: ["http://localhost:19006"]

  plug SqueezeWeb.Router
end
