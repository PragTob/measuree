defmodule Measuree.Metrics.MetricTest do
  use Measuree.DataCase, async: true

  alias Measuree.Metrics.Metric

  test "there is a minimum name lenght" do
    changeset = Metric.changeset(%Metric{}, %{name: ""})
    refute changeset.valid?

    assert %{name: ["can't be blank"]} = errors_on(changeset)
  end
end
