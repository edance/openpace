defmodule Squeeze.Strava.BulkImport do
  @moduledoc """
  Squeeze.Strava.BulkImport.import_from_file(user, "export_1234.zip")
  """

  require Logger

  alias Squeeze.Activities
  alias Squeeze.SlugGenerator
  alias Squeeze.FileParser.FitImport

  def import_from_file(user, filename) do
    Logger.info("[#{__MODULE__}] starting import of #{filename}")

    # Create working folder
    folder = Path.join(["tmp", SlugGenerator.gen_slug()])
    File.mkdir(folder)

    # Export the zip - some fun erlang
    :zip.unzip(to_charlist(filename), [{:cwd, to_charlist(folder)}])

    # Read the activities.csv
    # Create a stream to create activities, trackpoints, and laps
    Logger.info("[#{__MODULE__}] importing summary activities...")

    File.stream!(Path.join([folder, "activities.csv"]))
    |> CSV.decode(headers: true, escape_max_lines: 1000)
    |> Stream.map(fn row ->
      {:ok, csv_data} = row

      case create_summary_activity(user, csv_data) do
        {:ok, activity} ->
          activity

        {:error, _} ->
          Logger.error("Error creating activity")
      end
    end)
    |> Stream.run()

    # Import the detailed activity from fit files
    Logger.info("[#{__MODULE__}] importing detailed activities...")

    File.stream!(Path.join([folder, "activities.csv"]))
    |> CSV.decode(headers: true, escape_max_lines: 1000)
    |> Stream.map(fn row ->
      {:ok, csv_data} = row
      create_detailed_activity(user, csv_data, folder)
    end)
  end

  defp create_summary_activity(user, csv_data) do
    data = activity_from_csv(csv_data)
    Activities.create_activity(user, data)
  end

  defp create_detailed_activity(user, csv_data, folder) do
    data = load_data(Path.join([folder, csv_data["Filename"]]))
    activity = Activities.get_activity_by_external_id!(user, csv_data["Activity ID"])
    Activities.update_activity(activity, %{polyline: data.polyline})
    Activities.create_laps(activity, data.laps)
    Activities.create_trackpoint_set(activity, data.trackpoints)
  end

  defp load_data(filename) do
    Logger.info("[#{__MODULE__}] loading data from #{filename}")

    cond do
      String.contains?(filename, ".fit.gz") ->
        gunzip(filename)
        full_file = Path.absname(String.replace(filename, ".gz", ""))
        FitImport.import_from_file(full_file)

      String.contains?(filename, ".tcx") ->
        Logger.info("[#{__MODULE__}] skipping tcx files...")
        %{laps: [], trackpoints: [], polyline: nil}

      true ->
        %{laps: [], trackpoints: [], polyline: nil}
    end
  end

  defp gunzip(filename) do
    System.cmd("gzip", ["-d", filename])
  end

  defp activity_from_csv(activity) do
    %{
      name: activity["Activity Name"],
      type: activity["Activity Type"],
      activity_type: activity_type(activity),
      distance: to_float(activity["Distance"]),
      duration: to_int(activity["Moving Time"]),
      moving_time: to_int(activity["Moving Time"]),
      elapsed_time: to_int(activity["Elapsed Time"]),
      start_at: start_at(activity),
      start_at_local: start_at(activity),
      elevation_gain: to_float(activity["Elevation Gain"]),
      external_id: activity["Activity ID"],
      planned_date: start_at(activity) |> Timex.to_date()
    }
  end

  defp to_int(val) when is_list(val) do
    val |> List.last() |> to_int()
  end

  defp to_int(val) do
    case Integer.parse(val) do
      :error -> 0.0
      {num, _} -> num
    end
  end

  defp to_float(val) when is_list(val) do
    val |> List.last() |> to_float()
  end

  defp to_float(val) do
    case Float.parse(val) do
      :error -> 0.0
      {num, _} -> num
    end
  end

  defp start_at(activity) do
    Timex.parse!(activity["Activity Date"], "%b %-d, %Y, %-I:%M:%S %p", :strftime)
  end

  defp activity_type(activity) do
    type = Map.get(activity, "Activity Type")

    cond do
      String.contains?(type, "Run") -> :run
      String.contains?(type, "Ride") -> :bike
      String.contains?(type, "Swim") -> :swim
      true -> :other
    end
  end
end
