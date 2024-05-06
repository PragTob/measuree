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
end
