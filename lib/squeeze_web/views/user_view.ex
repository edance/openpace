defmodule SqueezeWeb.UserView do
  use SqueezeWeb, :view

  def title("new.html", _) do
    "Create an Account"
  end

  def title(_page, _assigns) do
    gettext("User")
  end
end
