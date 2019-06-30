defmodule Squeeze.Email do
  use Bamboo.Phoenix, view: SqueezeWeb.EmailView

  @moduledoc """
  Module for building emails
  """

  alias Squeeze.CompanyHelper

  def welcome_email(user) do
    base_email()
    |> to(user.email)
    |> subject("Welcome to OpenPace!")
    |> assign(:user, user)
    |> render(:welcome)
  end

  def reset_password_email(user, link) do
    base_email()
    |> to(user.email)
    |> subject("Your Reset Password Link")
    |> assign(:user, user)
    |> assign(:link, link)
    |> render(:reset_password)
  end

  defp base_email do
    new_email()
    |> from(CompanyHelper.team_email())
    |> bcc(CompanyHelper.team_email())
    |> put_layout({SqueezeWeb.LayoutView, :email})
  end
end
