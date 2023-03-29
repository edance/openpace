defmodule SqueezeWeb.ExportController do
  use SqueezeWeb, :controller
  @moduledoc false

  alias Squeeze.Accounts
  alias Squeeze.Activities

  def activities(conn, %{"slug" => slug}) do
    user = Accounts.get_user_by_slug!(slug)

    if user.user_prefs.api_enabled do
      render_csv_content(conn, user)
    else
      conn
      |> put_root_layout(false)
      |> send_resp(401, "")
    end
  end

  defp render_csv_content(conn, user) do
    csv_data = csv_content(Activities.list_activity_exports(user))

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"export.csv\"")
    |> put_root_layout(false)
    |> send_resp(200, csv_data)
  end

  defp csv_content(records) do
    records
    |> CSV.encode(headers: true)
    |> Enum.to_list()
    |> to_string()
  end
end
