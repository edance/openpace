defmodule SqueezeWeb.FlashComponent do
  use SqueezeWeb, :live_component
  @moduledoc false

  def info_msg(flash), do: live_flash(flash, :info)
  def error_msg(flash), do: live_flash(flash, :error)
end
