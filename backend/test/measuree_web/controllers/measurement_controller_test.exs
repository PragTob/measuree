defmodule MeasureeWeb.MeasurementControllerTest do
  use MeasureeWeb.ConnCase, async: true

  import Measuree.MetricsFixtures

  @create_attrs %{
    timestamp: ~U[2024-05-05 12:47:00Z],
    value: 120.5
  }
  @invalid_attrs %{timestamp: nil, value: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all measurements when empty", %{conn: conn} do
      conn = get(conn, ~p"/api/measurements")
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all measurements", %{conn: conn} do
      measurement =
        measurement_fixture(%{
          value: 10,
          timestamp: ~U[2024-05-05 12:47:00Z]
        })

      conn = get(conn, ~p"/api/measurements")

      assert json_response(conn, 200)["data"] == [
               %{"value" => 10, "timestamp" => "2024-05-05T12:47:00Z", "id" => measurement.id}
             ]
    end
  end

  describe "create measurement" do
    test "renders measurement when data is valid", %{conn: conn} do
      metric = metric_fixture()
      create_attrs = Map.put(@create_attrs, :metric_id, metric.id)

      conn = post(conn, ~p"/api/measurements", measurement: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/measurements/#{id}")

      assert %{
               "id" => ^id,
               "timestamp" => "2024-05-05T12:47:00Z",
               "value" => 120.5
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/measurements", measurement: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
