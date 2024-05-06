defmodule Measuree.Repo.Migrations.CreateMeasurements do
  use Ecto.Migration

  def change do
    create table(:measurements) do
      add :timestamp, :utc_datetime, null: false
      add :value, :float, null: false
      add :metric_id, references(:metrics, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:measurements, [:metric_id])
  end
end
