defmodule Dominos.Repo do
  use Ecto.Repo,
    otp_app: :dominos,
    adapter: Ecto.Adapters.Postgres
end
