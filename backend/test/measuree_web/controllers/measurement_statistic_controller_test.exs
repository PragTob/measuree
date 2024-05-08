defmodule MeasureeWeb.MeasurementStatisticControllerTest do
  use MeasureeWeb.ConnCase, async: true

  import Measuree.MetricsFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all measurement_statistics", %{conn: conn} do
      conn = get(conn, ~p"/api/measurement_statistics")
      assert json_response(conn, 200)["data"] == %{}
    end

    test "data is indexed by time bucket and metric", %{conn: conn} do
      stat = measurement_statistic_fixture()

      conn = get(conn, ~p"/api/measurement_statistics")

      assert json_response(conn, 200)["data"] == %{
               to_string(stat.time_bucket) => %{
                 to_string(stat.metric_id) => [
                   %{"time_start" => timestamp(stat.time_start), "average" => stat.average}
                 ]
               }
             }
    end

    test "2 metrics can be reported on", %{conn: conn} do
      stat = measurement_statistic_fixture()
      stat2 = measurement_statistic_fixture()

      conn = get(conn, ~p"/api/measurement_statistics")

      assert json_response(conn, 200)["data"] == %{
               to_string(stat.time_bucket) => %{
                 to_string(stat.metric_id) => [
                   %{"time_start" => timestamp(stat.time_start), "average" => stat.average}
                 ],
                 to_string(stat2.metric_id) => [
                   %{"time_start" => timestamp(stat2.time_start), "average" => stat2.average}
                 ]
               }
             }
    end

    test "There can be multiple values per metric and time bucket", %{conn: conn} do
      metric = metric_fixture()

      stat =
        measurement_statistic_fixture(%{
          metric: metric,
          time_start: ~U[2024-05-05 12:47:00Z],
          value: 100.88
        })

      stat2 =
        measurement_statistic_fixture(%{
          metric: metric,
          time_start: ~U[2024-05-05 12:48:00Z],
          value: 0.32
        })

      conn = get(conn, ~p"/api/measurement_statistics")

      assert json_response(conn, 200)["data"] == %{
               to_string(stat.time_bucket) => %{
                 to_string(stat.metric_id) => [
                   %{"time_start" => timestamp(stat.time_start), "average" => stat.average},
                   %{"time_start" => timestamp(stat2.time_start), "average" => stat2.average}
                 ]
               }
             }
    end
  end

  test "we can report on all time buckets", %{conn: conn} do
    metric = metric_fixture()

    measurement_statistic_fixture(%{metric: metric, time_bucket: :minute})
    measurement_statistic_fixture(%{metric: metric, time_bucket: :hour})
    measurement_statistic_fixture(%{metric: metric, time_bucket: :day})

    metric_id = to_string(metric.id)

    conn = get(conn, ~p"/api/measurement_statistics")

    assert %{
             "minute" => %{^metric_id => [_]},
             "hour" => %{^metric_id => [_]},
             "day" => %{^metric_id => [_]}
           } =
             json_response(conn, 200)["data"]
  end

  # JSON date time formatting, as Jason handles it
  defp timestamp(timestamp) do
    DateTime.to_iso8601(timestamp)
  end
end
