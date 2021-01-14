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

  describe "#format/2" do
    test "with imperial: true returns miles" do
      assert Distances.format(10_000, imperial: true) == "6.22 mi"
    end

    test "with imperial: false returns km" do
      assert Distances.format(10_000, imperial: false) == "10.0 km"
    end
  end

  test "#format/1 returns mi" do
    assert Distances.format(10_000) == "6.22 mi"
  end

  describe "#parse" do
    test "errors if no distance specified" do
      assert {:error} = Distances.parse("3")
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

    test "multiplication with junk" do
      assert {:error} = Distances.parse("4xjunk")
    end

    test "with junk" do
      assert {:error} = Distances.parse("junk")
    end
  end
end
