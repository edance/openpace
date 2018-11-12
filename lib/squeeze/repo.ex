defmodule Squeeze.Repo do
  use Ecto.Repo,
    otp_app: :squeeze,
    adapter: Ecto.Adapters.Postgres
end
