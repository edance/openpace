# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Squeeze.Repo.insert!(%Squeeze.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
import SweetXml

alias Faker.{Lorem}
alias Squeeze.Dashboard.Trackpoint
alias Squeeze.Repo
alias Squeeze.Races.{Race, Trackpoint}

{:ok, datetime} = NaiveDateTime.new(2019, 5, 25, 7, 15, 0)

race = %Race{
  name: "Bayshore Marathon",
  slug: "bayshore-marathon",
  address_line1: "1150 Milliken Dr.",
  city: "Traverse City",
  state: "MI",
  country: "US",
  postal_code: "49686",
  start_at: datetime,
  timezone: "America/New_York",
  overview: Lorem.paragraph(),
  description: Lorem.paragraph(3),
  distance: 42_195.0,
  distance_type: :marathon,
  url: "https://www.bayshoremarathon.org"
}
%{id: race_id} = Repo.insert!(race)

file_stream = File.stream!("Bayshore_Marathon.gpx")

trackpoints = file_stream
|> stream_tags([:trkpt])
|> Stream.map(fn {_, doc} ->
  lat = xpath(doc, ~x"./@lat"f)
  lon = xpath(doc, ~x"./@lon"f)
  altitude = xpath(doc, ~x"./ele/text()"f)
  %{coordinates: %{lat: lat, lon: lon}, altitude: altitude, race_id: race_id}
  end)
|> Enum.to_list()

first = trackpoints |> List.first() |> Map.put(:distance, 0.0)

{trackpoints, _} = trackpoints
|> Enum.map_reduce(first, fn(x, l) ->
  distance = Distance.GreatCircle.distance({x.coordinates.lon, x.coordinates.lat}, {l.coordinates.lon, l.coordinates.lat})
  trackpoint = Map.put(x, :distance, l.distance + distance)
  {trackpoint, trackpoint}
  end)

Repo.insert_all(Trackpoint, trackpoints)
