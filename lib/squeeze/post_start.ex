defmodule Squeeze.PostStart do
  @moduledoc false

  def run do
    File.touch("/tmp/app-initialized")
  end
end
