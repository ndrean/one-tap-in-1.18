defmodule LiveFlight.Repo do
  use Ecto.Repo,
    otp_app: :live_flight,
    adapter: Ecto.Adapters.Postgres
end
