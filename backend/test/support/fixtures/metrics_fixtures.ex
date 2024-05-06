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
        name: "some name"
      })
      |> Measuree.Metrics.create_metric()

    metric
  end
end
