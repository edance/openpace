defmodule Squeeze.Api.AuthPipeline do
  @moduledoc """
  This module defines the pipeline for auth allowing a shared error handler
  across api plugs.
  """

  use Guardian.Plug.Pipeline, otp_app: :squeeze,
    module: Squeeze.Guardian,
    error_handler: Squeeze.Api.AuthErrorHandler

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
