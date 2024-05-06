defmodule Measuree.Metrics.Metric do
  use Ecto.Schema
  import Ecto.Changeset

  schema "metrics" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(metric, attrs) do
    metric
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, min: 1)
    |> unique_constraint(:name)
  end
end
