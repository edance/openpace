defmodule SqueezeWeb.WizardController do
  use SqueezeWeb, :controller

  @steps ~w(race-date duration experience personal-record improvement connect)

  alias Squeeze.Accounts
  require IEx

  plug :validate_step when action in [:step]

  def index(conn, _params) do
    case get_session(conn, :current_step) do
      nil -> redirect(conn, to: page_path(conn, :index))
      step -> redirect(conn, to: wizard_path(conn, :step, step))
    end
  end

  def step(conn, %{"step"=> step}) do
    user = conn.assigns.current_user
    changeset = Accounts.change_user_prefs(user.user_prefs)
    render(conn, "#{step}.html", changeset: changeset)
  end

  def update(conn, %{"user_prefs" => pref_params}) do
    user = conn.assigns.current_user

    case Accounts.update_user_prefs(user.user_prefs, pref_params) do
      {:ok, goal} ->
        conn
        |> put_flash(:info, "Goal updated successfully.")
        |> redirect(to: page_path(conn, :index))
      # {:error, %Ecto.Changeset{} = changeset} ->
      #   render(conn, "#{step}.html", changeset: changeset)
    end
  end

  defp next_step(conn, _) do
  end

  defp validate_step(conn, _) do
    %{"step" => step} = conn.params
    case Enum.member?(@steps, step) do
      true -> put_session(conn, :current_step, step)
      false ->
        conn
        |> redirect(to: wizard_path(conn, :index))
        |> halt()
    end
  end
end
