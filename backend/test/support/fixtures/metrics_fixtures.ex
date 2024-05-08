defmodule Measuree.MetricsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Measuree.Metrics` context.
  """

  @doc """
  Generate a metric.
  """
  def metric_fixture(attrs \\ %{}) do
    {:ok, metric} =
      attrs
      |> Enum.into(%{
        # unique integer to avoid conflicts and also not slow down tests too much
        # https://hexdocs.pm/ecto_sql/Ecto.Adapters.SQL.Sandbox.html#module-database-locks-and-deadlocks
        name: "Metric #{System.unique_integer()}"
      })
      |> Measuree.Metrics.create_metric()

    metric
  end

  @doc """
  Generate a measurement.
  """
  def measurement_fixture(attrs \\ %{}) do
    metric = Map.get_lazy(attrs, :metric, fn -> metric_fixture() end)

    {:ok, measurement} =
      attrs
      |> Enum.into(%{
        timestamp: ~U[2024-05-05 12:47:00Z],
        value: 120.5,
        metric_id: metric.id
      })
      |> Measuree.Metrics.create_measurement()

    measurement
  end

  @doc """
  Generate a measurement_statistic.
  """
  def measurement_statistic_fixture(attrs \\ %{}) do
    metric = Map.get_lazy(attrs, :metric, fn -> metric_fixture() end)

    {:ok, measurement_statistic} =
      attrs
      |> Enum.into(%{
        average: 120.5,
        time_start: ~U[2024-05-07 09:13:00Z],
        time_bucket: :hour,
        metric_id: metric.id
      })
      |> Measuree.Metrics.create_measurement_statistic()

    measurement_statistic
  end
end
