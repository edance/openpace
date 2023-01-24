defmodule SqueezeWeb.NavbarComponent do
  use SqueezeWeb, :live_component
  @moduledoc false

  @allow_strava_upload Application.compile_env(:squeeze, :allow_strava_upload)

  defp show_bulk_import_link? do
    @allow_strava_upload
  end
end
