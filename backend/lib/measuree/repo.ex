defmodule Measuree.Repo do
  use Ecto.Repo,
    otp_app: :measuree,
    adapter: Ecto.Adapters.Postgres
end
