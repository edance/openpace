defmodule Squeeze.Api.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :my_app,
    module: Squeeze.Guardian,
    error_handler: Squeeze.Api.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
end
