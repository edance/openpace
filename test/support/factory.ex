defmodule Squeeze.Factory do
  use ExMachina.Ecto, repo: Squeeze.Repo

  @moduledoc false

  alias Faker.{Address, Date, Internet, Name}
  alias Squeeze.Accounts.{Credential, User, UserPrefs}
  alias Squeeze.Dashboard.{Activity, Event}

  def user_factory do
    %User{
      first_name: Name.first_name(),
      last_name: Name.last_name(),
      email: Internet.email(),
      city: Address.city(),
      state: Address.state_abbr(),
      country: Address.country_code(),
      user_prefs: %UserPrefs{}
    }
  end

  def credential_factory do
    %Credential{
      provider: "strava",
      token: "abcdefg",
      uid: 12_345,
      user: build(:user)
    }
  end

  def user_prefs_factory do
    %UserPrefs{
      distance: 42_195, # Marathon in meters
      duration: 3 * 60 * 60, # 3 hours in seconds
      personal_record: 3 * 60 * 60, # 3 hours in seconds
      name: "#{Address.city()} Marathon",
      race_date: Date.forward(:rand.uniform(100))
    }
  end

  def event_factory do
    %Event{
      cooldown: Enum.random([true, false]),
      warmup: Enum.random([true, false]),
      date: Date.forward(:rand.uniform(100)),
      distance: 120.5,
      name: "some name",
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
      polyline: "abc",
      user: build(:user)
    }
  end
end
