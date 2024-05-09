defmodule Measuree.Metrics.Measurement do
  use Ecto.Schema
  import Ecto.Changeset

  alias Measuree.Metrics.Metric

  @moduledoc """
  A single measurement submitted to the backend.

  Keeps track of what metric it is for, the value and the timestamp of when it's from.

  Basis for statistical calculations.
  """

  schema "measurements" do
    field :timestamp, :utc_datetime
    field :value, :float

    belongs_to :metric, Metric

    timestamps(type: :utc_datetime)
  end

  @attributes [:metric_id, :timestamp, :value]

  @doc false
  def changeset(measurement, attrs) do
    measurement
    |> cast(attrs, @attributes)
    |> validate_required(@attributes)
    |> foreign_key_constraint(:metric_id)
  end
end
