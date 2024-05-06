defmodule Measuree.MeasurementStatisticsCacheTest do
  use Measuree.DataCase, async: true

  import Measuree.MetricsFixtures
  import Ecto.Query

  alias Measuree.Metrics.MeasurementStatistics

  @timestamp ~U[2024-05-05 12:47:35Z]
  @minute_start_timestamp ~U[2024-05-05 12:47:00Z]
  @hour_start_timestamp ~U[2024-05-05 12:00:00Z]
  @day_start_timestamp ~U[2024-05-05 00:00:00Z]
  @precision 0.01

  describe "measurements caches" do
    test "inserting a single value filles the cache" do
      metric = metric_fixture()

      refute Repo.exists?(measurement_statistics_for_query(metric))

      measurement_fixture(%{value: 100.0, timestamp: @timestamp, metric: metric})

      assert statistics = measurement_statistics_for(metric)
      assert length(statistics) == 3
      # sorted by time_start
      assert [day, hour, minute] = statistics

      assert %MeasurementStatistics{time_bucket: :day, time_start: @day_start_timestamp} = day
      assert %MeasurementStatistics{time_bucket: :hour, time_start: @hour_start_timestamp} = hour

      assert %MeasurementStatistics{time_bucket: :minute, time_start: @minute_start_timestamp} =
               minute

      Enum.each(statistics, fn statistic ->
        assert_in_delta statistic.average, 100.0, @precision
      end)
    end

    test "creates the right average for 3 inserts" do
      metric = metric_fixture()

      refute Repo.exists?(measurement_statistics_for_query(metric))

      values = [10, 30, 60]

      Enum.each(values, fn value ->
        measurement_fixture(%{
          value: value,
          timestamp: @timestamp,
          metric: metric
        })
      end)

      assert statistics = measurement_statistics_for(metric)
      # minute, hour, day
      assert length(statistics) == 3

      Enum.each(statistics, fn statistic ->
        assert_in_delta statistic.average, 33.33, @precision
      end)
    end

    test "a time stamp a day later creates 3 more records" do
      metric = metric_fixture()

      timestamp = ~U[2024-05-05 23:59:59Z]
      measurement_fixture(%{value: 100.0, timestamp: timestamp, metric: metric})

      tomorrow_day_start = ~U[2024-05-06 00:00:00Z]
      value = 55.0
      measurement_fixture(%{value: value, timestamp: tomorrow_day_start, metric: metric})

      assert statistics = measurement_statistics_for(metric)

      assert [_day, _hour, _minute, tomorrow_day, tomorrow_hour, tomorrow_minute] = statistics

      # as the day start is also the start of the hour and minute all time_start values are the same
      assert %MeasurementStatistics{
               time_bucket: :day,
               time_start: ^tomorrow_day_start,
               average: ^value
             } = tomorrow_day

      assert %MeasurementStatistics{
               time_bucket: :hour,
               time_start: ^tomorrow_day_start,
               average: ^value
             } = tomorrow_hour

      assert %MeasurementStatistics{
               time_bucket: :minute,
               time_start: ^tomorrow_day_start,
               average: ^value
             } = tomorrow_minute
    end

    test "a time stamp in another minute creates 1 more record and differing averages" do
      metric = metric_fixture()

      timestamp = ~U[2024-05-05 12:47:59Z]
      value = 100.0
      measurement_fixture(%{value: value, timestamp: timestamp, metric: metric})
      next_minute = DateTime.add(timestamp, 1, :second)

      other_value = 24.0
      measurement_fixture(%{value: other_value, timestamp: next_minute, metric: metric})

      assert statistics = measurement_statistics_for(metric)

      assert [day, hour, minute, new_minute] = statistics

      new_average = 62

      assert_in_delta day.average, new_average, @precision
      assert_in_delta hour.average, new_average, @precision
      assert_in_delta minute.average, value, @precision

      assert %MeasurementStatistics{
               time_bucket: :minute,
               time_start: ^next_minute,
               average: ^other_value
             } = new_minute
    end

    test "inserting records from another metrics inserts separate records and does not affect averages" do
      metric = metric_fixture()
      other_metric = metric_fixture()

      value = 100.0
      measurement_fixture(%{value: value, timestamp: @timestamp, metric: metric})

      assert Repo.aggregate(MeasurementStatistics, :count, :id) == 3

      other_value = 42.0
      measurement_fixture(%{value: other_value, timestamp: @timestamp, metric: other_metric})

      assert Repo.aggregate(MeasurementStatistics, :count, :id) == 6

      assert statistics = measurement_statistics_for(metric)
      assert length(statistics) == 3
      Enum.each(statistics, &assert_in_delta(&1.average, value, @precision))

      assert other_statistics = measurement_statistics_for(other_metric)
      assert length(other_statistics) == 3
      Enum.each(other_statistics, &assert_in_delta(&1.average, other_value, @precision))
    end

    test "example where day, hour and minute averages all differ" do
      metric = metric_fixture()

      measurement_fixture(%{value: 22.73, timestamp: ~U[2024-05-05 12:47:59Z], metric: metric})
      measurement_fixture(%{value: 0.23, timestamp: ~U[2024-05-05 12:47:00Z], metric: metric})

      measurement_fixture(%{value: 67.12, timestamp: ~U[2024-05-05 12:46:59Z], metric: metric})
      measurement_fixture(%{value: 99.99, timestamp: ~U[2024-05-05 13:00:00Z], metric: metric})

      assert statistics = measurement_statistics_for(metric)

      # order of the query means we can assert this
      assert [day, hour1, minute1, minute2, hour2, minute3] = statistics

      assert_in_delta day.average, 47.52, @precision
      assert_in_delta hour1.average, 30.03, @precision
      assert_in_delta minute1.average, 67.12, @precision
      assert_in_delta minute2.average, 11.48, @precision
      assert_in_delta hour2.average, 99.99, @precision
      assert_in_delta minute3.average, 99.99, @precision
    end
  end

  defp measurement_statistics_for_query(query \\ MeasurementStatistics, metric) do
    query
    |> where(metric_id: ^metric.id)
    |> order_by(asc: :time_start, asc: :time_bucket)
  end

  defp measurement_statistics_for(query \\ MeasurementStatistics, metric) do
    query
    |> measurement_statistics_for_query(metric)
    |> Repo.all()
  end
end
