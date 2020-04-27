defmodule EveToolsApi.Scans.SurveyScan do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "survey_scan" do
    field :system, :string
    field :belt, :string
    field :total_value, :float
    field :total_volume, :float

    timestamps()
  end
end
