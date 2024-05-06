defmodule MeasureeWeb.MeasurementController do
  use MeasureeWeb, :controller

  alias Measuree.Metrics
  alias Measuree.Metrics.Measurement

  action_fallback MeasureeWeb.FallbackController

  def index(conn, _params) do
    measurements = Metrics.list_measurements()
    render(conn, :index, measurements: measurements)
  end

  def create(conn, %{"measurement" => measurement_params}) do
    with {:ok, %Measurement{} = measurement} <- Metrics.create_measurement(measurement_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/measurements/#{measurement}")
      |> render(:show, measurement: measurement)
    end
  end

  def show(conn, %{"id" => id}) do
    measurement = Metrics.get_measurement!(id)
    render(conn, :show, measurement: measurement)
  end
end
