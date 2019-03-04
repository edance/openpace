defmodule SqueezeWeb.UserView do
  use SqueezeWeb, :view

  def title(_page, _assigns) do
    gettext("User")
  end
end
