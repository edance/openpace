defmodule SqueezeWeb.Settings.PersonalRecordsFormComponent do
  @moduledoc """
  """

  use SqueezeWeb, :live_component

  alias Phoenix.LiveView.JS

  import Squeeze.Distances, only: [distance_name: 2]

  def pr_at_distance(%{current_user: user}, distance) do
    user.user_prefs.personal_records
    |> Enum.find(&(&1.distance == distance))
  end
end
