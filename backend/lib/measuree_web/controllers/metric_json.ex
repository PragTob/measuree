defmodule MeasureeWeb.MetricJSON do
  alias Measuree.Metrics.Metric

  @doc """
  Renders a list of metrics.
  """
  def index(%{metrics: metrics}) do
    %{data: for(metric <- metrics, do: data(metric))}
  end

  @doc """
  Renders a single metric.
  """
  def show(%{metric: metric}) do
    %{data: data(metric)}
  end

  defp data(%Metric{} = metric) do
    %{
      id: metric.id,
      name: metric.name
    }
  end
end
