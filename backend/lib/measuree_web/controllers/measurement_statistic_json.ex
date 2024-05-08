defmodule MeasureeWeb.MeasurementStatisticJSON do
  alias Measuree.Metrics.MeasurementStatistic

  @doc """
  Renders a list of measurement_statistics.
  """
  def index(%{measurement_statistics: measurement_statistics}) do
    %{data: grouped_data(measurement_statistics)}
  end

  # we want to achieve a structure that is:
  #
  defp grouped_data(statistics) do
    statistics
    |> Enum.group_by(& &1.time_bucket)
    |> Map.new(fn {key, value} ->
      data = Enum.group_by(value, & &1.metric_id, &data/1)
      {key, data}
    end)
  end

  defp data(%MeasurementStatistic{} = measurement_statistic) do
    %{
      average: measurement_statistic.average,
      time_start: measurement_statistic.time_start
    }
  end
end
