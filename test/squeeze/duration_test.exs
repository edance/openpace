defmodule Squeeze.DurationTest do
  use ExUnit.Case

  alias Squeeze.Duration

  test "cast/1" do
    assert Duration.cast(1) == {:ok, 1}
    assert Duration.cast("01:00") == {:ok, 60}
    assert Duration.cast("01:11") == {:ok, 71}
    assert Duration.cast("3:01:11") == {:ok, 10_871}
    assert Duration.cast("35:00:00") == {:ok, 126_000}
  end
end
