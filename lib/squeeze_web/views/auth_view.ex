defmodule SqueezeWeb.AuthView do
  use SqueezeWeb, :view

  def title(_page, _assigns) do
    gettext("Sign into your Account")
  end
end
