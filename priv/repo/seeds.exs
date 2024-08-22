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

import Squeeze.Factory
import Squeeze.Utils, only: [random_int: 2, random_float: 2]

# Make the default user with personal records
user = insert(:user, email: "a@b.co")

# Get the root of the project
project_root = Path.expand("../..", __DIR__)

# Get all the polylines from the file
polylines =
  Path.join([project_root, "polylines.csv"])
  |> File.stream!()
  |> CSV.decode(headers: true)
  |> Enum.map(fn {:ok, row} -> row["polyline"] end)

# Add upcoming races for the user
pr = user.user_prefs.personal_records |> List.last()

# Race Goal 90 seconds to 5 minutes faster
goal_duration = pr.duration - random_int(90, 5 * 60)
insert(:race_goal, distance: pr.distance, duration: goal_duration, user: user)

total_days = 365

0..total_days
|> Enum.map(fn i ->
  IO.puts("#{i} out of #{total_days}")

  # Running six random days a week
  if :rand.uniform() < 6 / 7 do
    # Run in the morning (but latest at noon)
    hour = Enum.random(6..12)
    # Get a random polyline from polylines list
    polyline = Enum.random(polylines)

    # for every 1 out of 3 days
    workout_type = if rem(i, 3) == 0, do: :workout, else: nil
    workout_type = if rem(i, 7) == 0, do: :long_run, else: workout_type

    start_at = Timex.now() |> Timex.shift(days: -i) |> Timex.set(hour: hour)

    insert(:activity,
      start_at: start_at,
      user: user,
      workout_type: workout_type,
      polyline: polyline,
      external_id: nil
    )
  end
end)

# Make a challenge
challenge = insert(:challenge) |> with_scores()

# Add user to challenge
amount_max =
  case challenge.challenge_type do
    # 100 miles
    :distance -> 100 * 1609
    # 100 hours
    :time -> 100 * 60 * 60
    # 300 meters
    :altitude -> 300
    # 1 hour
    _ -> 60 * 60
  end

insert(:score, user: user, challenge: challenge, amount: random_float(1, amount_max))

# Activties that aren't runs

# Past challenges

# Past races

# Laps for activities
