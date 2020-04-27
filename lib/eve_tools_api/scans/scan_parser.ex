defmodule EveToolsApi.Scans.ScanParser do
  @keys [:ore, :asteroid_amt, :ore_vol, :asteroid_dist]

  def handle_scan(raw_scan) do
    results = raw_scan
              |> String.split("\n", trim: true)
              |> Enum.map(&parse_line/1)
              |> Enum.filter(fn val -> val != nil end)

    distinct_ores = results |> Enum.uniq_by(fn %{:ore => ore} -> ore end) |> Enum.map(fn map -> map[:ore] end)
    HTTPoison.start()
    {_, json_ores} = Jason.encode(distinct_ores)
    response = HTTPoison.post! "https://esi.evetech.net/latest/universe/ids/?datasource=tranquility&language=en-us", json_ores, [{"Content-Type", "application/json"}]

    {_, %{"inventory_types" => ore_type_ids}} = Jason.decode(response.body)

    prices = ore_type_ids
             |> Enum.map(&lookup_price/1)
             |> Enum.reduce(Map.new, fn x, acc -> Map.put(acc, x["name"], x["average"]) end)

    final = results
            |> Enum.map(fn result -> Map.put(result, :total_isk, Map.get(prices, result[:ore], 0) * result[:asteroid_amt]) end)
            |> Enum.map(fn result -> Map.put(result, :ore_family, determine_ore_family(result)) end)
            |> Enum.group_by(fn result -> result[:ore_family] end)



#    IO.inspect(final)

    final
  end

  defp parse_line(line) do
    split_result = line
                   |> String.trim
                   |> String.split("\t")

    case Enum.count(split_result) do
      4 -> split_result |> line_to_map
      _ -> nil
    end
  end

  defp line_to_map(list) do
    new_list = Enum.map(list, fn item -> String.replace(item, ",", "") end)
    line_map = Enum.zip(@keys, new_list)
               |> Enum.into(%{})

    {asteroid_amt, ""} = Integer.parse(line_map[:asteroid_amt])
    {ore_vol, ""} = String.split(line_map[:ore_vol])
                    |> List.first
                    |> Integer.parse

    Map.put(line_map, :asteroid_amt, asteroid_amt)
    |> Map.put(:ore_vol, ore_vol)
  end

  defp lookup_price(type) do
    ConCache.get_or_store(:esi_cache, "price_#{type["id"]}", fn ->
      {:ok, historical_prices} = "https://esi.evetech.net/latest/markets/10000002/history?type_id=#{type["id"]}"
                                 |> HTTPoison.get!
                                 |> Map.get(:body)
                                 |> Jason.decode

      yesterdays_price_info = historical_prices
                              |> Enum.find(fn price_entry -> price_entry["date"] == "2020-04-16" end)
                              |> Map.put("name", type["name"])
    end)
  end

  defp determine_ore_family(ore) do
    family_name = String.split(ore[:ore], " ") |> List.last
  end
end
