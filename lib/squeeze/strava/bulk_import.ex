defmodule Squeeze.Strava.BulkImport do
  @moduledoc """
  Squeeze.Strava.BulkImport.import_from_file(user, "export_1234.zip")
  """

  require Logger

  alias Squeeze.Dashboard
  alias Squeeze.SlugGenerator

  def import_from_file(user, filename) do
    Logger.info("[#{__MODULE__}] starting import of #{filename}")

    # Create working folder
    folder = Path.join(["tmp", SlugGenerator.gen_slug()])
    File.mkdir(folder)

    # Export the zip - some fun erlang
    :zip.unzip(to_charlist(filename), [{:cwd, to_charlist(folder)}])

    # Read the activities.csv
    # Create a stream to create activities, trackpoints, and laps
    File.stream!(Path.join([folder, "activities.csv"]))
    |> CSV.decode(headers: true, escape_max_lines: 1000)
    |> Stream.map(fn row ->
      with {:ok, %{"Activity ID" => external_id} = csv_data} <- row,
           {:error, :not_found} <- Dashboard.fetch_activity_by_external_id(user, external_id) do
        create_detailed_activity(user, csv_data, folder)
      else
        {:ok, activity} -> activity
      end
    end)
  end

  defp create_detailed_activity(user, csv_data, folder) do
    data = load_data(Path.join([folder, csv_data["Filename"]]))
    data = Map.merge(activity_from_csv(csv_data), data)

    case Dashboard.create_activity(user, data) do
      {:ok, activity} ->
        Dashboard.create_laps(activity, data.laps)
        Dashboard.create_trackpoint_set(activity, data.trackpoints)
        activity
      error -> error
    end
  end

  defp load_data(filename) do
    if String.contains?(filename, ".fit.gz") do
      System.cmd("gzip", ["-d", filename])
      full_file = Path.absname(String.replace(filename, ".gz", ""))
      Squeeze.FileParser.FitImport.import_from_file(full_file)
    else
      %{
        laps: [],
        trackpoints: []
      }
    end
  end

  def to_naive_datetime(t) do
    t
    |> Timex.to_naive_datetime()
    |> NaiveDateTime.truncate(:second)
  end

  defp activity_from_csv(activity) do
    %{
      name: activity["Activity Name"],
      type: activity["Activity Type"],
      activity_type: activity_type(activity),
      distance: distance(activity),
      duration: moving_time(activity),
      moving_time: moving_time(activity),
      elapsed_time: elapsed_time(activity),
      start_at: start_at(activity),
      start_at_local: start_at(activity),
      elevation_gain: to_float(activity["Elevation Gain"]),
      external_id: activity["Activity ID"],
      planned_date: start_at(activity) |> Timex.to_date()
    }
  end

  defp distance(activity) do
    try  do
      {distance, _} = activity["Distance"] |> List.last() |> Float.parse()
      distance
    rescue
      _e -> 0.0
    end
  end

  defp moving_time(activity) do
    {duration, _} = activity["Moving Time"] |> Integer.parse()
    duration
  end

  defp elapsed_time(activity) do
    {duration, _} = activity["Elapsed Time"] |> Integer.parse()
    duration
  end

  defp start_at(activity) do
    Timex.parse!(activity["Activity Date"], "%b %-d, %Y, %-I:%M:%S %p", :strftime)
  end

  defp to_float(num) do
    case Float.parse(num) do
      :error -> 0.0
      {num, _} -> num
    end
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
