defmodule Squeeze.UtilsTest do
  use Squeeze.DataCase

  @moduledoc false

  import Squeeze.Utils, only: [cast_float: 1]

  describe "#cast_float/1" do
    test "returns nil for nil" do
      assert cast_float(nil) == nil
    end

    test "casts integers to floats" do
      assert cast_float(1) == 1.0
    end

    test "works with floats" do
      assert cast_float(1.0) == 1.0
    end
  end
end
