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
end
