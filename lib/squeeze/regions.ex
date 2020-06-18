defmodule Squeeze.Regions do
  @moduledoc """
  This module defines regions used for races.
  """

  @regions [
    %{short_name: "AK", long_name: "Alaska"},
    %{short_name: "AL", long_name: "Alabama"},
    %{short_name: "AR", long_name: "Arkansas"},
    %{short_name: "AZ", long_name: "Arizona"},
    %{short_name: "CA", long_name: "California"},
    %{short_name: "CO", long_name: "Colorado"},
    %{short_name: "CT", long_name: "Connecticut"},
    %{short_name: "DE", long_name: "Delaware"},
    %{short_name: "FL", long_name: "Florida"},
    %{short_name: "GA", long_name: "Georgia"},
    %{short_name: "HI", long_name: "Hawaii"},
    %{short_name: "IA", long_name: "Iowa"},
    %{short_name: "ID", long_name: "Idaho"},
    %{short_name: "IL", long_name: "Illinois"},
    %{short_name: "IN", long_name: "Indiana"},
    %{short_name: "KS", long_name: "Kansas"},
    %{short_name: "KY", long_name: "Kentucky"},
    %{short_name: "LA", long_name: "Louisiana"},
    %{short_name: "MA", long_name: "Massachusetts"},
    %{short_name: "MD", long_name: "Maryland"},
    %{short_name: "ME", long_name: "Maine"},
    %{short_name: "MI", long_name: "Michigan"},
    %{short_name: "MN", long_name: "Minnesota"},
    %{short_name: "MO", long_name: "Missouri"},
    %{short_name: "MS", long_name: "Mississippi"},
    %{short_name: "MT", long_name: "Montana"},
    %{short_name: "NC", long_name: "North Carolina"},
    %{short_name: "ND", long_name: "North Dakota"},
    %{short_name: "NE", long_name: "Nebraska"},
    %{short_name: "NH", long_name: "New Hampshire"},
    %{short_name: "NJ", long_name: "New Jersey"},
    %{short_name: "NM", long_name: "New Mexico"},
    %{short_name: "NV", long_name: "Nevada"},
    %{short_name: "NY", long_name: "New York"},
    %{short_name: "OH", long_name: "Ohio"},
    %{short_name: "OK", long_name: "Oklahoma"},
    %{short_name: "OR", long_name: "Oregon"},
    %{short_name: "PA", long_name: "Pennsylvania"},
    %{short_name: "RI", long_name: "Rhode Island"},
    %{short_name: "SC", long_name: "South Carolina"},
    %{short_name: "SD", long_name: "South Dakota"},
    %{short_name: "TN", long_name: "Tennessee"},
    %{short_name: "TX", long_name: "Texas"},
    %{short_name: "UT", long_name: "Utah"},
    %{short_name: "VA", long_name: "Virginia"},
    %{short_name: "VT", long_name: "Vermont"},
    %{short_name: "WA", long_name: "Washington"},
    %{short_name: "DC", long_name: "Washington DC"},
    %{short_name: "WI", long_name: "Wisconsin"},
    %{short_name: "WV", long_name: "West Virginia"},
    %{short_name: "WY", long_name: "Wyoming"}
  ]

  def states do
    @regions
  end

  def from_short_name(short_name) do
    Enum.find(@regions, &(&1.short_name == short_name))
  end
end
