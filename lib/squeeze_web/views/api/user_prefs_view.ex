defmodule SqueezeWeb.Api.UserPrefsView do
  use SqueezeWeb, :view

  def render("user_prefs.json", %{user_prefs: user_prefs}) do
    %{
      timezone: user_prefs.timezone,
      imperial: user_prefs.imperial,
      gender: user_prefs.gender,
      birthdate: user_prefs.birthdate
    }
  end
end
