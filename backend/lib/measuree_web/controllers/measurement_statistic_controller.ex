defmodule MeasureeWeb.MeasurementStatisticController do
  use MeasureeWeb, :controller

  alias Measuree.Metrics

  action_fallback MeasureeWeb.FallbackController

  def index(conn, _params) do
    measurement_statistics = Metrics.list_measurement_statistics()
    render(conn, :index, measurement_statistics: measurement_statistics)
  end
end
