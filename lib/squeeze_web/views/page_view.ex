defmodule SqueezeWeb.PageView do
  use SqueezeWeb, :view

  def distances() do
    [
      "5k": 5000,
      "10k": 10000,
      "Half Marathon": 21097,
      "Marathon": 42195
    ]
  end
end
