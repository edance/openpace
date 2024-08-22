defmodule Squeeze.Namer.EmojiFormatter do
  @moduledoc """
  This module returns an emoji for an activity type
  """

  @default_emoji %{
    # https://emojipedia.org/skier/
    "AlpineSki" => "⛷️",
    # https://emojipedia.org/skier/
    "BackcountrySki" => "⛷",
    # https://emojipedia.org/canoe/
    "Canoeing" => "🛶",
    "Crossfit" => nil,
    # https://emojipedia.org/bicyclist/
    "EBikeRide" => "🚴",
    "Elliptical" => nil,
    # https://emojipedia.org/golfer/
    "Golf" => "🏌️️",
    "Handcycle" => nil,
    # https://emojipedia.org/hiking-boot/
    "Hike" => "🥾",
    # https://emojipedia.org/ice-skate/
    "IceSkate" => "⛸️",
    "InlineSkate" => nil,
    "Kayaking" => nil,
    "Kitesurf" => nil,
    "NordicSki" => nil,
    # https://emojipedia.org/bicyclist/
    "Ride" => "🚴",
    # https://emojipedia.org/person-climbing/
    "RockClimbing" => "🧗",
    "RollerSki" => nil,
    # https://emojipedia.org/rowboat/
    "Rowing" => "🚣",
    # https://emojipedia.org/runner/
    "Run" => "🏃",
    # https://emojipedia.org/sailboat/
    "Sail" => "⛵",
    # https://emojipedia.org/skateboard/
    "Skateboard" => "🛹",
    # https://emojipedia.org/snowboarder/
    "Snowboard" => "🏂",
    "Snowshoe" => nil,
    # https://emojipedia.org/soccer-ball/
    "Soccer" => "⚽",
    "StairStepper" => nil,
    "StandUpPaddling" => nil,
    # https://emojipedia.org/surfer/
    "Surfing" => "🏄",
    # https://emojipedia.org/swimmer/
    "Swim" => "🏊",
    "Velomobile" => nil,
    # https://emojipedia.org/bicyclist/
    "VirtualRide" => "🚴",
    "VirtualRun" => nil,
    # https://emojipedia.org/pedestrian/
    "Walk" => "🚶",
    # https://emojipedia.org/weight-lifter/
    "WeightTraining" => "🏋️",
    "Wheelchair" => nil,
    "Windsurf" => nil,
    "Workout" => nil,
    # https://emojipedia.org/person-in-lotus-position/
    "Yoga" => "🧘"
  }

  @female_emoji_map %{
    # https://emojipedia.org/woman-biking/
    "EBikeRide" => "🚴‍♀",
    # https://emojipedia.org/woman-golfing/
    "Golf" => "🏌️‍♀️",
    # https://emojipedia.org/woman-biking/
    "Ride" => "🚴‍♀",
    # https://emojipedia.org/woman-climbing/
    "RockClimbing" => "🧗‍♀",
    # https://emojipedia.org/woman-rowing-boat/
    "Rowing" => "🚣‍♀",
    # https://emojipedia.org/woman-running/
    "Run" => "🏃‍♀",
    # https://emojipedia.org/woman-surfing/
    "Surfing" => "🏄‍♀",
    # https://emojipedia.org/woman-swimming/
    "Swim" => "🏊‍♀",
    # https://emojipedia.org/woman-biking/
    "VirtualRide" => "🚴‍♀",
    # https://emojipedia.org/woman-walking/
    "Walk" => "🚶‍♀",
    # https://emojipedia.org/woman-weight-lifting/
    "WeightTraining" => "🏋️‍♀️",
    # https://emojipedia.org/woman-in-lotus-position/
    "Yoga" => "🧘‍♀"
  }

  def format(%{type: type}, emoji: true, gender: :female) do
    @female_emoji_map[type] || @default_emoji[type]
  end

  def format(activity, emoji: true, gender: _), do: format(activity, emoji: true)
  def format(%{type: type}, emoji: true), do: @default_emoji[type]
  def format(_, _), do: nil
end
