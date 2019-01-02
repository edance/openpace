defmodule Squeeze.Factory do
  use ExMachina.Ecto, repo: Squeeze.Repo

  use Squeeze.ActivityFactory
  use Squeeze.CredentialFactory
  use Squeeze.UserFactory
  use Squeeze.UserPrefsFactory

  @moduledoc false

  alias Faker.{Date}
  alias Squeeze.Dashboard.{Event}

  def event_factory do
    %Event{
      cooldown: Enum.random([true, false]),
      warmup: Enum.random([true, false]),
      date: Date.forward(100),
      distance: 120.5,
      name: "some name",
      user: build(:user)
    }
  end
end
