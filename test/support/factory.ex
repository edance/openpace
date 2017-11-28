defmodule Squeeze.Factory do
  use ExMachina.Ecto, repo: Squeeze.Repo

  alias Faker.{Name, Lorem, Address}
  alias Squeeze.Accounts.User
  alias Squeeze.Dashboard.{Activity, Event, Goal, Pace}

  def user_factory do
    %User{
      first_name: Name.first_name(),
      last_name: Name.last_name(),
      email: Faker.Internet.email(),
      description: Lorem.paragraph(),
      avatar: "",
      city: Address.city(),
      state: Address.state_abbr(),
      country: Address.country_code()
    }
  end

  def goal_factory do
    %Goal{
      current: true,
      date: Faker.Date.forward(:rand.uniform(100)),
      distance: 42195.0, # Marathon in meters
      duration: 3 * 60 * 60, # 3 hours in seconds
      name: "#{Address.city()} Marathon",
      user: build(:user)
    }
  end

  def pace_factory do
    %Pace{
      name: Enum.random(["Easy", "Tempo", "Speed", "Long"]),
      offset: :rand.uniform(120), # Random offset up to 120 seconds
      user: build(:user)
    }
  end

  def event_factory do
    %Event{
      cooldown: Enum.random([true, false]),
      warmup: Enum.random([true, false]),
      date: Faker.Date.forward(:rand.uniform(100)),
      distance: 120.5,
      name: "some name",
      pace: build(:pace),
      user: build(:user)
    }
  end

  def activity_factory do
    miles = Enum.random(2..16) # 2-16 miles
    pace = Enum.random(5..8) # 5-9 min/miles
    %Activity{
      distance: miles * 1609.0,
      duration: pace * miles * 60,
      name: Enum.random(["Morning Run", "Afternoon Run", "Evening Run"]),
      start_at: DateTime.utc_now,
      external_id: sequence(:external_id, fn(x) -> x end),
      user: build(:user)
    }
  end
end
