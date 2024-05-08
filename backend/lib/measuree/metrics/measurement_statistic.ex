defmodule Measuree.Metrics.MeasurementStatistic do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  A cache for the statistics about measurements.

  Only calculates the `average` so far but is extensible for other statistics (such as min/max etc).
  Update is done via PostgreSQL triggers.
  """

  schema "measurement_statistics" do
    field :average, :float
    field :time_bucket, Ecto.Enum, values: [:minute, :hour, :day]
    field :time_start, :utc_datetime

    belongs_to :metric, Measuree.Metrics.Metric

    timestamps(type: :utc_datetime)
  end

  @attributes [:metric_id, :average, :time_bucket, :time_start]

  @doc false
  def changeset(measurement_statistics, attrs) do
    measurement_statistics
    |> cast(attrs, @attributes)
    |> validate_required(@attributes)
  end
end
