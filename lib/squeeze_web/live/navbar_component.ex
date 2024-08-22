defmodule SqueezeWeb.NavbarComponent do
  use SqueezeWeb, :live_component
  @moduledoc false

  alias Phoenix.LiveView.JS

  def show_user_dropdown() do
    JS.show(
      to: "#user-dropdown-menu",
      transition:
        {"transition ease-out duration-100", "transform opacity-0 scale-95",
         "transform opacity-100 scale-100"}
    )
  end

  def hide_user_dropdown() do
    JS.hide(
      to: "#user-dropdown-menu",
      transition:
        {"transition ease-in duration-75", "transform opacity-100 scale-100",
         "transform opacity-0 scale-95"}
    )
  end

  def toggle_mobile_menu() do
    JS.toggle(
      to: "#mobile-menu",
      in:
        {"transition ease-out duration-100", "transform opacity-0 scale-95",
         "transform opacity-100 scale-100"},
      out:
        {"transition ease-out duration-100", "transform opacity-100 scale-100",
         "transform opacity-0 scale-95"}
    )
  end
end
