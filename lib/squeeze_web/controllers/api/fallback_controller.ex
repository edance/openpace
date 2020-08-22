defmodule SqueezeWeb.Api.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use SqueezeWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(SqueezeWeb.Api.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(SqueezeWeb.Api.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(SqueezeWeb.Api.ErrorView)
    |> render(:"401")
  end

  def call(conn, {:error, _}) do
    conn
    |> put_status(:not_allowed)
    |> put_view(SqueezeWeb.Api.ErrorView)
    |> render(:"400")
  end
end
