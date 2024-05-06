defmodule MeasureeWeb.MetricController do
  use MeasureeWeb, :controller

  alias Measuree.Metrics

  action_fallback MeasureeWeb.FallbackController

  def index(conn, _params) do
    metrics = Metrics.list_metrics()
    render(conn, :index, metrics: metrics)
  end
end
