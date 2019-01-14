defmodule Squeeze.VelocityTest do
  use Squeeze.DataCase

  @moduledoc false

  alias Squeeze.Velocity

  describe "to_float/2" do
    test "when velocity is zero, it returns zero" do
      assert Velocity.to_float(0.0) == 0.0
    end

    test "when imperial: true, it returns minutes per mile" do
      assert Velocity.to_float(3.4, imperial: true) == 7.89
    end

    test "when imperial: false, it returns minutes per kilometer" do
      assert Velocity.to_float(3.4, imperial: false) == 4.9
    end
  end
end
