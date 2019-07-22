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
alias Faker.{Lorem}
alias Squeeze.Repo
alias Squeeze.Races.{Event, Race}

{:ok, datetime} = NaiveDateTime.new(2019, 5, 25, 7, 15, 0)

race = %Race{
  name: "Bayshore Marathon",
  slug: "bayshore-marathon",
  address_line1: "1150 Milliken Dr.",
  city: "Traverse City",
  state: "MI",
  country: "US",
  postal_code: "49686",
  timezone: "America/New_York",
  content: Lorem.paragraph(20),
  url: "https://www.bayshoremarathon.org"
}
%{id: race_id} = Repo.insert!(race)

event = %Event{
  name: "Marathon",
  details: "",
  start_at: datetime,
  distance: 42_195.0,
  distance_name: "Marathon",
  race_id: race_id
}
Repo.insert!(event)

alias Squeeze.Accounts
alias Squeeze.TrainingPlans.{Plan, Event}

{:ok, %{id: user_id}} = Accounts.create_guest_user()

plan = %Plan{
  name: "Advanced Marathon Training Plan",
  experience_level: :advanced,
  week_count: 18,
  description: "",
  user_id: user_id
}
%{id: plan_id} = Repo.insert!(plan)

Enum.map(0..(18 * 7 - 1), fn(x) ->
  dist = Enum.random(4..16)
  pace = Enum.random(["easy", "tempo", "long run"])

  event = %Event{
    name: "#{dist} miles #{pace}",
    type: "Run",
    distance: dist * 1_609.0,
    duration: nil,
    warmup: false,
    cooldown: false,
    plan_position: x,
    day_position: 0,
    training_plan_id: plan_id
  }
  Repo.insert!(event)
end)
