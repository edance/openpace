defmodule Squeeze.SplitTest do
  use Squeeze.DataCase

  @moduledoc false

  import Squeeze.Factory
  alias Squeeze.Split

  describe "calculate_splits/2" do
    setup [:build_user]

    test "without any streams returns an empty list", %{user: user} do
      stream_set = %{distance: nil, time: nil}
      assert Split.calculate_splits(user, stream_set) == []
    end

    test "without distance values returns an empty list", %{user: user} do
      stream_set = %{distance: nil, time: %{data: time_stream()}}
      assert Split.calculate_splits(user, stream_set) == []
    end

    test "with valid streams", %{user: user} do
      stream_set = %{distance: %{data: distance_stream()},
                     time: %{data: time_stream()}}
      splits = Split.calculate_splits(user, stream_set)
      last_split = List.last(splits)
      assert length(splits) == 3
      assert last_split.distance == 3
      assert last_split.pace == 8 * 60
      assert last_split.total_time == 8 * 60 * 3
    end
  end

  defp build_user(_) do
    {:ok, user: build(:user)}
  end

  defp time_stream do
    0..3 |> Enum.map(&(&1 * 8 * 60)) # 8 min miles
  end

  defp distance_stream do
    0..3 |> Enum.map(&(&1 * 1609)) # 0-3 miles
  end
end
