defmodule MeasureeWeb.MeasurementJSON do
  alias Measuree.Metrics.Measurement

  @doc """
  Renders a list of measurements.
  """
  def index(%{measurements: measurements}) do
    %{data: for(measurement <- measurements, do: data(measurement))}
  end

  @doc """
  Renders a single measurement.
  """
  def show(%{measurement: measurement}) do
    %{data: data(measurement)}
  end

  defp data(%Measurement{} = measurement) do
    %{
      id: measurement.id,
      timestamp: measurement.timestamp,
      value: measurement.value
    }
  end
end
