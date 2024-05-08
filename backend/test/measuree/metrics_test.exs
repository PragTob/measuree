defmodule Measuree.MetricsTest do
  use Measuree.DataCase, async: true

  alias Measuree.Metrics

  describe "metrics" do
    alias Measuree.Metrics.Metric

    import Measuree.MetricsFixtures

    @invalid_attrs %{name: nil}

    test "list_metrics/0 returns all metrics" do
      metric = metric_fixture()
      assert Metrics.list_metrics() == [metric]
    end

    test "get_metric!/1 returns the metric with given id" do
      metric = metric_fixture()
      assert Metrics.get_metric!(metric.id) == metric
    end

    test "create_metric/1 with valid data creates a metric" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Metric{} = metric} = Metrics.create_metric(valid_attrs)
      assert metric.name == "some name"
    end

    test "create_metric/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Metrics.create_metric(@invalid_attrs)
    end

    test "create_metric/1 with a duplicated name returns an error" do
      attrs = %{name: "some name"}

      assert {:ok, _metric} = Metrics.create_metric(attrs)
      assert {:error, changeset} = Metrics.create_metric(attrs)

      refute changeset.valid?
      assert [name: {_msg, [{:constraint, :unique} | _more_error_details]}] = changeset.errors
    end

    test "update_metric/2 with valid data updates the metric" do
      metric = metric_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Metric{} = metric} = Metrics.update_metric(metric, update_attrs)
      assert metric.name == "some updated name"
    end

    test "update_metric/2 with invalid data returns error changeset" do
      metric = metric_fixture()
      assert {:error, %Ecto.Changeset{}} = Metrics.update_metric(metric, @invalid_attrs)
      assert metric == Metrics.get_metric!(metric.id)
    end

    test "delete_metric/1 deletes the metric" do
      metric = metric_fixture()
      assert {:ok, %Metric{}} = Metrics.delete_metric(metric)
      assert_raise Ecto.NoResultsError, fn -> Metrics.get_metric!(metric.id) end
    end

    test "change_metric/1 returns a metric changeset" do
      metric = metric_fixture()
      assert %Ecto.Changeset{} = Metrics.change_metric(metric)
    end
  end

  describe "measurements" do
    alias Measuree.Metrics.Measurement

    import Measuree.MetricsFixtures

    @invalid_attrs %{timestamp: nil, value: nil}

    test "list_measurements/0 returns all measurements" do
      measurement = measurement_fixture()
      assert Metrics.list_measurements() == [measurement]
    end

    test "get_measurement!/1 returns the measurement with given id" do
      measurement = measurement_fixture()
      assert Metrics.get_measurement!(measurement.id) == measurement
    end

    test "create_measurement/1 with valid data creates a measurement" do
      valid_attrs = %{
        timestamp: ~U[2024-05-05 12:47:00Z],
        value: 120.5,
        metric_id: metric_fixture().id
      }

      assert {:ok, %Measurement{} = measurement} = Metrics.create_measurement(valid_attrs)
      assert measurement.timestamp == ~U[2024-05-05 12:47:00Z]
      assert measurement.value == 120.5
    end

    test "create_measurement/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Metrics.create_measurement(@invalid_attrs)
    end

    test "create_measurement/1 without a valid reference to a metric fails" do
      fake_metric_id = 9999

      attrs = %{
        timestamp: ~U[2024-05-05 12:47:00Z],
        value: 120.5,
        metric_id: fake_metric_id
      }

      assert {:error, changeset} = Metrics.create_measurement(attrs)
      assert %{metric_id: ["does not exist"]} = errors_on(changeset)
    end

    test "update_measurement/2 with valid data updates the measurement" do
      measurement = measurement_fixture()
      update_attrs = %{timestamp: ~U[2024-05-06 12:47:00Z], value: 456.7}

      assert {:ok, %Measurement{} = measurement} =
               Metrics.update_measurement(measurement, update_attrs)

      assert measurement.timestamp == ~U[2024-05-06 12:47:00Z]
      assert measurement.value == 456.7
    end

    test "update_measurement/2 with invalid data returns error changeset" do
      measurement = measurement_fixture()
      assert {:error, %Ecto.Changeset{}} = Metrics.update_measurement(measurement, @invalid_attrs)
      assert measurement == Metrics.get_measurement!(measurement.id)
    end

    test "delete_measurement/1 deletes the measurement" do
      measurement = measurement_fixture()
      assert {:ok, %Measurement{}} = Metrics.delete_measurement(measurement)
      assert_raise Ecto.NoResultsError, fn -> Metrics.get_measurement!(measurement.id) end
    end

    test "change_measurement/1 returns a measurement changeset" do
      measurement = measurement_fixture()
      assert %Ecto.Changeset{} = Metrics.change_measurement(measurement)
    end
  end

  describe "measurement_statitics" do
    alias Measuree.Metrics.MeasurementStatistic

    import Measuree.MetricsFixtures

    test "list_measurement_statitics/0 returns all measurement_statitics" do
      measurement_statistic = measurement_statistic_fixture()
      assert Metrics.list_measurement_statitics() == [measurement_statistic]
    end

    test "create_measurement_statistic/1 with valid data creates a measurement_statistic" do
      metric = metric_fixture()

      valid_attrs = %{
        average: 120.5,
        time_start: ~U[2024-05-07 09:13:00Z],
        time_bucket: :hour,
        metric_id: metric.id
      }

      assert {:ok, %MeasurementStatistic{} = measurement_statistic} =
               Metrics.create_measurement_statistic(valid_attrs)

      assert measurement_statistic.average == 120.5
      assert measurement_statistic.time_start == ~U[2024-05-07 09:13:00Z]
      assert measurement_statistic.time_bucket == :hour
    end
  end
end
