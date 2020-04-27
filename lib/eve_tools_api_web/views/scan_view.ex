defmodule EveToolsApiWeb.ScanView do
  @moduledoc false
  use EveToolsApiWeb, :view

  def render("scan.json", %{scan: scan}) do
    %{id: scan.id, system: scan.system, belt: scan.belt, value: scan.total_value, m3: scan.total_volume}
  end
end
