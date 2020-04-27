defmodule EveToolsApi.Repo do
  use Ecto.Repo,
    otp_app: :eve_tools_api,
    adapter: Ecto.Adapters.Postgres
end
