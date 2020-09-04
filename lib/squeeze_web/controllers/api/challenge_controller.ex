defmodule SqueezeWeb.Api.ChallengeController do
  use SqueezeWeb, :controller

  def index(conn, _) do
    render(conn, %{})
  end

  def create(conn, _) do
    conn
    |> put_status(:not_implemented)
    |> render(conn, %{})
  end

  def update(_, _) do
  end
end
