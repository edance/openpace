defmodule Squeeze.DistancesTest do
  use Squeeze.DataCase

  @moduledoc false

  alias Squeeze.Distances

  test "mile_in_meters" do
    assert Distances.mile_in_meters == 1609
  end

  test '#distances' do
    %{name: name, distance: distance} = Distances.distances
    |> List.first()
    assert is_binary(name)
    assert is_integer(distance)
  end

  describe "#from_meters" do
    test 'returns the name of the event if found' do
      assert Distances.from_meters(5_000) == %{name: "5k", distance: 5_000}
    end
  end

  describe "#parse" do
    test "default number to miles" do
      assert {:ok, distance} = Distances.parse("3")
      assert distance == Distances.mile_in_meters * 3
    end

    test "parse for mi" do
      assert {:ok, distance} = Distances.parse("12mi")
      assert distance == 1609 * 12
    end

    test "parse for miles" do
      assert {:ok, distance} = Distances.parse("12 miles")
      assert distance == 1609 * 12
    end

    test "parse for km" do
      assert {:ok, distance} = Distances.parse("5 km")
      assert distance == 5000
    end

    test "parse for k" do
      assert {:ok, distance} = Distances.parse("5k")
      assert distance == 5000
    end

    test "parse for m" do
      assert {:ok, distance} = Distances.parse("1600m")
      assert distance == 1600
    end

    test "multiplication with mile repeats" do
      assert {:ok, distance} = Distances.parse("4 x 1mi")
      assert distance == 1609 * 4
    end

    test "multiplication with km repeats" do
      assert {:ok, distance} = Distances.parse("4 x 1km")
      assert distance == 1000 * 4
    end

    test "multiplication with m repeats" do
      assert {:ok, distance} = Distances.parse("4x1600m")
      assert distance == 1600 * 4
    end
  end
end
