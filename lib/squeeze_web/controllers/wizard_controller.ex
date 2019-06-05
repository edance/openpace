defmodule SqueezeWeb.WizardController do
  use SqueezeWeb, :controller

  @steps ~w(distance race-date duration experience personal-record improvement)

  alias Squeeze.Accounts

  plug :validate_step when action in [:step, :update]

  def index(conn, _params) do
    case get_session(conn, :current_step) do
      nil -> redirect(conn, to: Routes.wizard_path(conn, :step, List.first(@steps)))
      step -> redirect(conn, to: Routes.wizard_path(conn, :step, step))
    end
  end

  def step(conn, %{"step"=> step}) do
    user = conn.assigns.current_user
    changeset = Accounts.change_user_prefs(user.user_prefs)
    render(conn, "step.html", changeset: changeset, step: step)
  end

  def update(conn, %{"step" => step, "user_prefs" => pref_params}) do
    user = conn.assigns.current_user
    next_step = next_step(step)

    case Accounts.update_user_prefs(user.user_prefs, pref_params) do
      {:ok, _} ->
        conn
        |> redirect(to: Routes.wizard_path(conn, :step, next_step))
      {:error, %Ecto.Changeset{} = changeset} ->
        render_error(conn, changeset, step)
    end
  end

  defp render_error(conn, changeset, step)  do
    render(conn, "step.html", changeset: changeset, step: step)
  end

  defp step_index(step) do
    Enum.find_index(@steps, fn(x) -> x == step end)
  end

  defp next_step(step) do
    Enum.at(@steps, step_index(step) + 1)
  end

  defp validate_step(conn, _) do
    %{"step" => step} = conn.params
    case Enum.member?(@steps, step) do
      true -> put_session(conn, :current_step, step)
      false ->
        conn
        |> put_status(:not_found)
        |> put_view(SqueezeWeb.ErrorView)
        |> render("404.html")
        |> halt()
    end
  end
end
