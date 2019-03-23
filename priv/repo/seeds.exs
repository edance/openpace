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
alias Squeeze.Races.Race

race = %Race{
  name: "Bayshore Marathon",
  slug: "bayshore-marathon",
  address_line1: "1150 Milliken Dr.",
  city: "Traverse City",
  state: "MI",
  country: "US",
  postal_code: "49686",
  overview: Lorem.paragraph(),
  description: Lorem.paragraph(3),
  distance: 42_195.0,
  distance_type: :marathon,
  url: "https://www.bayshoremarathon.org"
}
Repo.insert!(race)
