defmodule MeasureeWeb.MetricControllerTest do
  use MeasureeWeb.ConnCase, async: true

  import Measuree.MetricsFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all metrics when empty", %{conn: conn} do
      conn = get(conn, ~p"/api/metrics")
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all metrics", %{conn: conn} do
      metric = metric_fixture(name: "My Metric")
      conn = get(conn, ~p"/api/metrics")
      assert json_response(conn, 200)["data"] == [%{"name" => "My Metric", "id" => metric.id}]
    end
  end
end
