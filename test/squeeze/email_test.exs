defmodule Squeeze.EmailTest do
  use Squeeze.DataCase

  alias Squeeze.Email

  import Squeeze.Factory

  test "welcome email" do
    user = insert(:user)

    email = Email.welcome_email(user)

    assert email.to == user.email
    assert email.from == {"The OpenPace Team", "team@openpace.co"}
    assert email.html_body =~ "Welcome to the OpenPace family!"
    assert email.text_body =~ "Welcome to the OpenPace family!"
  end
end
