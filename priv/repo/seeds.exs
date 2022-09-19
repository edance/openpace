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
import Squeeze.Utils, only: [random_int: 2]

# Make the default user with personal records
user = insert(:user, email: "a@b.co")

# Add upcoming races for the user
pr = user.user_prefs.personal_records |> List.last()
goal_duration = pr.duration - random_float(90, 5 * 60) # Race Goal 90 seconds to 5 minutes faster
insert(:race_goal, distance: pr.distance, duration: goal_duration, user: user)

# Add activities for the user (for the ninety days)
(0..90)
|> Enum.map(fn i ->
  if :rand.uniform() < (6 / 7) do # Running six random days a week
    hour = Enum.random(6..12) # Run in the morning (but latest at noon)
    start_at = Timex.now() |> Timex.shift(days: -i) |> Timex.set(hour: hour)
    insert(:activity, start_at: start_at, user: user, external_id: nil)
  end
end)
365

# Make a challenge
challenge = insert(:challenge) |> with_scores()

# Add user to challenge
insert(:score, user: user, challenge: challenge)
