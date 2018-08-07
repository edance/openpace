defmodule SqueezeWeb.WizardController do
  use SqueezeWeb, :controller

  @steps ~w(race-date duration experience personal-record improvement connect)

  require IEx

  plug :validate_step when action in [:step]

  def index(conn, _params) do
    step = get_session(conn, :current_step) || @steps[0]
    redirect(conn, to: wizard_path(conn, :step, step))
  end

  def step(conn, %{"step" => step}) do
    render(conn, "#{step}.html")
  end

  def update(conn, _params) do
    conn
    |> put_flash(:info, "Nice")
    |> redirect(to: page_path(conn, :index))
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
