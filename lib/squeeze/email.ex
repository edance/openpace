defmodule Squeeze.Email do
  use Bamboo.Phoenix, view: SqueezeWeb.EmailView

  @moduledoc """
  Module for building emails
  """

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
    |> from("OpenPace Team <team@openpace.co>")
    |> put_layout({SqueezeWeb.LayoutView, :email})
  end
end
