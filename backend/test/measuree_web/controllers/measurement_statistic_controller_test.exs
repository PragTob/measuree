defmodule MeasureeWeb.MeasurementStatisticControllerTest do
  use MeasureeWeb.ConnCase

  import Measuree.MetricsFixtures

  alias Measuree.Metrics.MeasurementStatistic

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all measurement_statitics", %{conn: conn} do
      conn = get(conn, ~p"/api/measurement_statitics")
      assert json_response(conn, 200)["data"] == []
    end
  end
end
