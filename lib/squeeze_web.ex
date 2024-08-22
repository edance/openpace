defmodule SqueezeWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use SqueezeWeb, :controller
      use SqueezeWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: SqueezeWeb
      import Plug.Conn
      import SqueezeWeb.Gettext

      alias SqueezeWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/squeeze_web/templates",
        namespace: SqueezeWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1, get_csrf_token: 0]

      # Include shared imports and aliases for views
      unquote(html_helpers())

      import Squeeze.CompanyHelper
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView, layout: {SqueezeWeb.LayoutView, :live}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import SqueezeWeb.Gettext
    end
  end

  defp html_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView helpers (live_render, live_component, live_patch, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      # Core UI components and translation
      import SqueezeWeb.CoreComponents
      import SqueezeWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      import SqueezeWeb.FormHelpers
      import SqueezeWeb.FormatHelpers
      import SqueezeWeb.ErrorHelpers
      import SqueezeWeb.HoneypotInput
      import SqueezeWeb.ImageHelpers
      alias SqueezeWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
