defmodule Thames.Repo do
  use Ecto.Repo,
    otp_app: :thames,
    adapter: Ecto.Adapters.Postgres
end
