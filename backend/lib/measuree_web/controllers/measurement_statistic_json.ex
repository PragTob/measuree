defmodule MeasureeWeb.MeasurementStatisticJSON do
  alias Measuree.Metrics.MeasurementStatistic

  @doc """
  Renders a list of measurement_statitics.
  """
  def index(%{measurement_statitics: measurement_statitics}) do
    %{data: for(measurement_statistic <- measurement_statitics, do: data(measurement_statistic))}
  end

  @doc """
  Renders a single measurement_statistic.
  """
  def show(%{measurement_statistic: measurement_statistic}) do
    %{data: data(measurement_statistic)}
  end

  defp data(%MeasurementStatistic{} = measurement_statistic) do
    %{
      id: measurement_statistic.id,
      average: measurement_statistic.average,
      time_start: measurement_statistic.time_start
    }
  end
end
