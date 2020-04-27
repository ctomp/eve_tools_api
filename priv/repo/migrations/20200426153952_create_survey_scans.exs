defmodule EveToolsApi.Repo.Migrations.CreateSurveyScans do
  use Ecto.Migration

  def change do
    create table(:survey_scan) do
      add :system, :string, null: false
      add :belt, :string, null: false
      add :total_value, :float
      add :total_volume, :float

      timestamps()
    end
  end
end
