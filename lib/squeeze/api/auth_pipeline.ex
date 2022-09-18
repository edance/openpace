defmodule Squeeze.Api.AuthPipeline do
  @moduledoc false

  use Guardian.Plug.Pipeline, otp_app: :squeeze,
    module: Squeeze.Guardian,
    error_handler: Squeeze.Api.AuthErrorHandler

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
