defmodule Squeeze.AuthPipeline do
  @moduledoc """
  This module defines the pipeline for auth allowing a shared error handler
  across all plugs.
  """

  use Guardian.Plug.Pipeline, otp_app: :squeeze,
    module: Squeeze.Guardian,
    error_handler: Squeeze.AuthErrorHandler

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.LoadResource, allow_blank: true
end
