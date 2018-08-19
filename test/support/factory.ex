defmodule Squeeze.Factory do
  use ExMachina.Ecto, repo: Squeeze.Repo

  alias Faker.{Name, Address}
  alias Squeeze.Accounts.{Credential, User, UserPrefs}
  alias Squeeze.Dashboard.{Activity, Event, Pace}

  def user_factory do
    %User{
      first_name: Name.first_name(),
      last_name: Name.last_name(),
      email: Faker.Internet.email(),
      city: Address.city(),
      state: Address.state_abbr(),
      country: Address.country_code(),
      user_prefs: build(:user_prefs)
    }
  end

  def credential_factory do
    %Credential{
      provider: "strava",
      token: "abcdefg",
      uid: 12345,
      user: build(:user)
    }
  end

  def user_prefs_factory do
    %UserPrefs{
      distance: 42195, # Marathon in meters
      duration: 3 * 60 * 60, # 3 hours in seconds
      personal_record: 3 * 60 * 60, # 3 hours in seconds
      name: "#{Address.city()} Marathon",
      race_date: Faker.Date.forward(:rand.uniform(100))
    }
  end

  def pace_factory do
    %Pace{
      name: Enum.random(["Easy", "Tempo", "Speed", "Long"]),
      offset: :rand.uniform(120), # Random offset up to 120 seconds
      color: "##{Faker.Color.rgb_hex()}",
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
