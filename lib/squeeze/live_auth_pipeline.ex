defmodule Squeeze.LiveAuthPipeline do
  @moduledoc """
  This module defines the pipeline for live view auth allowing a shared error handler
  across all plugs.
  """

  use Guardian.Plug.Pipeline,
    otp_app: :squeeze,
    module: Squeeze.Guardian,
    error_handler: Squeeze.AuthErrorHandler

  plug Guardian.Plug.VerifySession
  plug SqueezeWeb.Plug.VerifyRememberMe
  plug Guardian.Plug.EnsureAuthenticated
end
