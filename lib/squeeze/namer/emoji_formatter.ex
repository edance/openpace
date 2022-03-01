defmodule Squeeze.Namer.EmojiFormatter do
  @moduledoc """
  This module returns an emoji for an activity type
  """

  @default_emoji %{
    "AlpineSki" => "⛷️", # https://emojipedia.org/skier/
    "BackcountrySki" => "⛷", # https://emojipedia.org/skier/
    "Canoeing" => "🛶", # https://emojipedia.org/canoe/
    "Crossfit" => nil,
    "EBikeRide" => "🚴", # https://emojipedia.org/bicyclist/
    "Elliptical" => nil,
    "Golf" => "🏌️️", # https://emojipedia.org/golfer/
    "Handcycle" => nil,
    "Hike" => "🥾", # https://emojipedia.org/hiking-boot/
    "IceSkate" => "⛸️", # https://emojipedia.org/ice-skate/
    "InlineSkate" => nil,
    "Kayaking" => nil,
    "Kitesurf" => nil,
    "NordicSki" => nil,
    "Ride" => "🚴", # https://emojipedia.org/bicyclist/
    "RockClimbing" => "🧗", # https://emojipedia.org/person-climbing/
    "RollerSki" => nil,
    "Rowing" => "🚣", # https://emojipedia.org/rowboat/
    "Run" => "🏃", # https://emojipedia.org/runner/
    "Sail" => "⛵", # https://emojipedia.org/sailboat/
    "Skateboard" => "🛹", # https://emojipedia.org/skateboard/
    "Snowboard" => "🏂", # https://emojipedia.org/snowboarder/
    "Snowshoe" => nil,
    "Soccer" => "⚽", # https://emojipedia.org/soccer-ball/
    "StairStepper" => nil,
    "StandUpPaddling" => nil,
    "Surfing" => "🏄", # https://emojipedia.org/surfer/
    "Swim" => "🏊", # https://emojipedia.org/swimmer/
    "Velomobile" => nil,
    "VirtualRide" => "🚴", # https://emojipedia.org/bicyclist/
    "VirtualRun" => nil,
    "Walk" => "🚶", # https://emojipedia.org/pedestrian/
    "WeightTraining" => "🏋️", # https://emojipedia.org/weight-lifter/
    "Wheelchair" => nil,
    "Windsurf" => nil,
    "Workout" => nil,
    "Yoga" => "🧘" # https://emojipedia.org/person-in-lotus-position/
  }

  @female_emoji_map %{
    "EBikeRide" => "🚴‍♀", # https://emojipedia.org/woman-biking/
    "Golf" => "🏌️‍♀️", # https://emojipedia.org/woman-golfing/
    "Ride" => "🚴‍♀", # https://emojipedia.org/woman-biking/
    "RockClimbing" => "🧗‍♀", # https://emojipedia.org/woman-climbing/
    "Rowing" => "🚣‍♀", # https://emojipedia.org/woman-rowing-boat/
    "Run" => "🏃‍♀", # https://emojipedia.org/woman-running/
    "Surfing" => "🏄‍♀", # https://emojipedia.org/woman-surfing/
    "Swim" => "🏊‍♀", # https://emojipedia.org/woman-swimming/
    "VirtualRide" => "🚴‍♀", # https://emojipedia.org/woman-biking/
    "Walk" => "🚶‍♀", # https://emojipedia.org/woman-walking/
    "WeightTraining" => "🏋️‍♀️", # https://emojipedia.org/woman-weight-lifting/
    "Yoga" => "🧘‍♀" # https://emojipedia.org/woman-in-lotus-position/
  }

  def format(%{type: type}, [emoji: true, gender: :female]) do
    @female_emoji_map[type] || @default_emoji[type]
  end
  def format(activity, [emoji: true, gender: _]), do: format(activity, emoji: true)
  def format(%{type: type}, [emoji: true]), do: @default_emoji[type]
  def format(_, _), do: nil
end
