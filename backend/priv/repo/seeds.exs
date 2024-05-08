# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Measuree.Repo.insert!(%Measuree.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Measuree.Repo
alias Measuree.Metrics.Measurement
alias Measuree.Metrics.Metric

# default is microseconds, makes the insert fail
now = DateTime.truncate(DateTime.utc_now(), :second)
timestamps_map = %{updated_at: now, inserted_at: now}

# insert_all is faster but doesn't provice time stamps, so let's add them real quick
# we could also use placeholders, but the complexity of this is not needed right now
add_time_stamps = fn list ->
  Enum.map(list, fn map ->
    Map.merge(timestamps_map, map)
  end)
end

# random air related metrics grabbed from Wikipedia
metrics_data = [
  %{name: "CO2"},
  %{name: "CO"},
  %{name: "SO2"},
  %{name: "NO2"},
  %{name: "O3"},
  %{name: "PM10"}
]

{_no_inserts, metrics} = Repo.insert_all(Metric, add_time_stamps.(metrics_data), returning: true)

base_day = ~U[2024-05-01 00:00:00Z]

measurement_data =
  Enum.flat_map(metrics, fn metric ->
    # some randomization to make the metrics feel different
    metric_amount = Enum.random(1_000..2_000)
    metric_range_min = Enum.random(-2_000..1_000)
    metric_range_max = Enum.random(2_000..20_000)

    Enum.map(1..metric_amount, fn _count ->
      # file ~ 1 week worth of data
      day = Enum.random(10..16)
      hour = Enum.random(0..23)
      minute = Enum.random(0..59)

      timestamp = %DateTime{base_day | day: day, hour: hour, minute: minute}

      %{
        # /100 to get some floats
        value: Enum.random(metric_range_min..metric_range_max) / 100,
        metric_id: metric.id,
        timestamp: timestamp
      }
    end)
  end)

# the insert goes fine on my system, on a slower system one may need to increase the timeout but here it's ~6seconds which is well in range
Repo.insert_all(Measurement, add_time_stamps.(measurement_data))
