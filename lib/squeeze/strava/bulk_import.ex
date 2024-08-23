defmodule Squeeze.Strava.BulkImport do
  @moduledoc """
  Squeeze.Strava.BulkImport.import_from_file(user, "export_1234.zip")
  """

  require Logger

  alias Squeeze.Activities
  alias Squeeze.SlugGenerator
  alias Squeeze.FileParser.{FitImport, TcxImport}

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
           {:error, :not_found} <- Activities.fetch_activity_by_external_id(user, external_id) do
        create_detailed_activity(user, csv_data, folder)
      else
        {:ok, activity} -> activity
      end
    end)
  end

  defp create_detailed_activity(user, csv_data, folder) do
    data = load_data(Path.join([folder, csv_data["Filename"]]))
    data = Map.merge(activity_from_csv(csv_data), data)

    case Activities.create_activity(user, data) do
      {:ok, activity} ->
        create_laps(activity, data.laps)
        Activities.create_trackpoint_set(activity, data.trackpoints)
        activity

      {:error, _changeset} ->
        Logger.warn("Cannot create #{data[:name]}")
    end
  end

  defp load_data(filename) do
    cond do
      String.contains?(filename, ".fit.gz") ->
        System.cmd("gzip", ["-d", filename])
        full_file = Path.absname(String.replace(filename, ".gz", ""))
        FitImport.import_from_file(full_file)

      String.contains?(filename, ".tcx") ->
        TcxImport.import_from_file(filename)

      true ->
        %{laps: [], trackpoints: []}
    end
  end

  def create_laps(activity, laps) do
    fields = ~w(
      average_cadence
      average_speed
      distance
      elapsed_time
      end_index
      lap_index
      max_speed
      moving_time
      name
      pace_zone
      split
      start_date
      start_date_local
      start_index
      total_elevation_gain
    )a

    laps = laps |> Enum.map(fn lap -> Map.take(lap, fields) end)
    Activities.create_laps(activity, laps)
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
