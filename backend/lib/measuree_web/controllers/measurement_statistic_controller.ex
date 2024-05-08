defmodule MeasureeWeb.MeasurementStatisticController do
  use MeasureeWeb, :controller

  alias Measuree.Metrics

  action_fallback MeasureeWeb.FallbackController

  def index(conn, _params) do
    measurement_statitics = Metrics.list_measurement_statitics()
    render(conn, :index, measurement_statitics: measurement_statitics)
  end
end
