defmodule EveToolsApiWeb.ScanController do
  use EveToolsApiWeb, :controller
  @moduledoc false

  alias EveToolsApi.Scans

  def index(conn, _params) do
    scans = Scans.list_scans()
    json(conn, scans)
  end

  def show(conn, %{"id" => id}) do
    json(conn, Scans.get_scan(id))
  end

  def create(conn, survey_scan) do
    {:ok, new_scan} = Scans.create_scan(survey_scan)
    render(conn, "scan.json", %{scan: new_scan})
  end
end
