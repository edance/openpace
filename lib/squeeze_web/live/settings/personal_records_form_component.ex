defmodule SqueezeWeb.Settings.PersonalRecordsFormComponent do
  @moduledoc """
  """

  use SqueezeWeb, :live_component
  import Squeeze.Distances, only: [distances: 0, distance_name: 2]

  def pr_at_distance(%{current_user: user}, distance) do
    user.user_prefs.personal_records
    |> Enum.find(&(&1.distance == distance))
  end
end
