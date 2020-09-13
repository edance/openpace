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

alias Squeeze.Accounts
import Squeeze.Factory

# Make the default user
user_params = params_for(:user, email: "a@b.co", encrypted_password: "password")
{:ok, user} = Accounts.register_user(user_params)

# Make a few challenges
challenges = (1..10) |> Enum.map(fn _ -> insert(:challenge) |> with_scores() end)

# Add user to all challenges
challenges |> Enum.map(fn x -> insert(:score, user: user, challenge: x) end)
