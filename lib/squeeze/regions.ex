defmodule Squeeze.Regions do
  @moduledoc """
  This module defines regions used for races.
  """

  @regions [
    %{short_name: "AK", long_name: "Alaska", slug: "alaska"},
    %{short_name: "AL", long_name: "Alabama", slug: "alabama"},
    %{short_name: "AR", long_name: "Arkansas", slug: "arkansas"},
    %{short_name: "AZ", long_name: "Arizona", slug: "arizona"},
    %{short_name: "CA", long_name: "California", slug: "california"},
    %{short_name: "CO", long_name: "Colorado", slug: "colorado"},
    %{short_name: "CT", long_name: "Connecticut", slug: "connecticut"},
    %{short_name: "DE", long_name: "Delaware", slug: "delaware"},
    %{short_name: "FL", long_name: "Florida", slug: "florida"},
    %{short_name: "GA", long_name: "Georgia", slug: "georgia"},
    %{short_name: "HI", long_name: "Hawaii", slug: "hawaii"},
    %{short_name: "IA", long_name: "Iowa", slug: "iowa"},
    %{short_name: "ID", long_name: "Idaho", slug: "idaho"},
    %{short_name: "IL", long_name: "Illinois", slug: "illinois"},
    %{short_name: "IN", long_name: "Indiana", slug: "indiana"},
    %{short_name: "KS", long_name: "Kansas", slug: "kansas"},
    %{short_name: "KY", long_name: "Kentucky", slug: "kentucky"},
    %{short_name: "LA", long_name: "Louisiana", slug: "louisiana"},
    %{short_name: "MA", long_name: "Massachusetts", slug: "massachusetts"},
    %{short_name: "MD", long_name: "Maryland", slug: "maryland"},
    %{short_name: "ME", long_name: "Maine", slug: "maine"},
    %{short_name: "MI", long_name: "Michigan", slug: "michigan"},
    %{short_name: "MN", long_name: "Minnesota", slug: "minnesota"},
    %{short_name: "MO", long_name: "Missouri", slug: "missouri"},
    %{short_name: "MS", long_name: "Mississippi", slug: "mississippi"},
    %{short_name: "MT", long_name: "Montana", slug: "montana"},
    %{short_name: "NC", long_name: "North Carolina", slug: "north-carolina"},
    %{short_name: "ND", long_name: "North Dakota", slug: "north-dakota"},
    %{short_name: "NE", long_name: "Nebraska", slug: "nebraska"},
    %{short_name: "NH", long_name: "New Hampshire", slug: "new-hampshire"},
    %{short_name: "NJ", long_name: "New Jersey", slug: "new-jersey"},
    %{short_name: "NM", long_name: "New Mexico", slug: "new-mexico"},
    %{short_name: "NV", long_name: "Nevada", slug: "nevada"},
    %{short_name: "NY", long_name: "New York", slug: "new-york"},
    %{short_name: "OH", long_name: "Ohio", slug: "ohio"},
    %{short_name: "OK", long_name: "Oklahoma", slug: "oklahoma"},
    %{short_name: "OR", long_name: "Oregon", slug: "oregon"},
    %{short_name: "PA", long_name: "Pennsylvania", slug: "pennsylvania"},
    %{short_name: "RI", long_name: "Rhode Island", slug: "rhode-island"},
    %{short_name: "SC", long_name: "South Carolina", slug: "south-carolina"},
    %{short_name: "SD", long_name: "South Dakota", slug: "south-dakota"},
    %{short_name: "TN", long_name: "Tennessee", slug: "tennessee"},
    %{short_name: "TX", long_name: "Texas", slug: "texas"},
    %{short_name: "UT", long_name: "Utah", slug: "utah"},
    %{short_name: "VA", long_name: "Virginia", slug: "virginia"},
    %{short_name: "VT", long_name: "Vermont", slug: "vermont"},
    %{short_name: "WA", long_name: "Washington", slug: "washington"},
    %{short_name: "DC", long_name: "Washington DC", slug: "washington-dc"},
    %{short_name: "WI", long_name: "Wisconsin", slug: "wisconsin"},
    %{short_name: "WV", long_name: "West Virginia", slug: "west-virginia"},
    %{short_name: "WY", long_name: "Wyoming", slug: "wyoming"}
  ]

  def states do
    @regions
  end

  def from_short_name(short_name) do
    Enum.find(@regions, &(&1.short_name == short_name))
  end

  def from_slug(slug) do
    Enum.find(@regions, &(&1.slug == slug))
  end
end
