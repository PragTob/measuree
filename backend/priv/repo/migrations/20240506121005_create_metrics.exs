defmodule Measuree.Repo.Migrations.CreateMetrics do
  use Ecto.Migration

  def change do
    create table(:metrics) do
      add :name, :string, null: false

      timestamps type: :utc_datetime
    end

    create unique_index("metrics", [:name])
  end
end
