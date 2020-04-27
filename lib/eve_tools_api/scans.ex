defmodule EveToolsApi.Scans do
  @moduledoc false

  alias EveToolsApi.Repo
  alias EveToolsApi.Scans.SurveyScan
  alias EveToolsApi.Scans.ScanParser

  def list_scans do
    Repo.all(SurveyScan)
  end

  def get_scan(id) do
    Repo.get(SurveyScan, id)
  end

  def get_scan!(id) do
    Repo.get!(SurveyScan, id)
  end

  def create_scan(scan_input \\ "") do
    parse_results = ScanParser.handle_scan(scan_input["scan_results"])
    total_isk = parse_results
    |> Enum.reduce(0, fn {k,v}, acc -> acc + add_total_isk(v) end)
    total_m3 = parse_results
    |> Enum.reduce(0, fn {k,v}, acc -> acc + add_total_m3(v) end)
    %SurveyScan{system: scan_input["system"], belt: "Teonusude IV - Asteroid Belt 2", total_value: total_isk, total_volume: total_m3}
    |> Repo.insert()
  end

  defp add_total_isk(ore_list) do
    Enum.reduce(ore_list, 0.0, fn ore, acc -> ore[:total_isk] + acc end)
  end

  defp add_total_m3(ore_list) do
    Enum.reduce(ore_list, 0.0, fn ore, acc -> ore[:ore_vol] + acc end)
  end
end
