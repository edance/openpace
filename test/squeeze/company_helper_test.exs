defmodule Squeeze.CompanyHelperTest do
  use Squeeze.DataCase, async: true

  alias Squeeze.CompanyHelper

  test "#company_name/0" do
    assert CompanyHelper.company_name() == "OpenPace"
  end

  test "#team_email/0" do
    assert CompanyHelper.team_email() ==
             {"The OpenPace Team", "team@openpace.co"}
  end
end
