defmodule Measuree.Repo.Migrations.CreateMeasurementStatistics do
  use Ecto.Migration

  def change do
    create_time_bucket_enum()
    create_table()
    create_cache_update_trigger()
  end

  defp create_time_bucket_enum do
    create_query = "CREATE TYPE time_bucket_type AS ENUM ('minute', 'hour', 'day')"
    drop_query = "DROP TYPE time_bucket_type"
    execute(create_query, drop_query)
  end

  defp create_table do
    create table(:measurement_statistics) do
      add :average, :float, null: false
      add :time_bucket, :string, null: false
      add :time_start, :utc_datetime, null: false
      add :metric_id, references(:metrics, on_delete: :nothing), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:measurement_statistics, [:metric_id, :time_bucket, :time_start])
  end

  # This may be controversial, see decisions section in README.
  # But in short, the database is great at doing this, and it's also easy to move should we decide to move it.
  defp create_cache_update_trigger do
    # They all need to be separate as you can't send multiple commands at once
    create_cache_update_helper()
    create_cache_update_function()
    create_trigger()
  end

  defp create_cache_update_helper do
    # They could be in a separate `.sql` file but that would make it too easy to edit them
    # without realizing changes won't be applied and at worst, causing different behaviours
    # on different machines. Having them IN the migration makes it clearer they should not
    # just be edited.
    create_query = """
    CREATE OR REPLACE FUNCTION update_measurement_statistics(given_metric_id bigint, given_time_bucket time_bucket_type, given_time_start TIMESTAMP, given_time_end TIMESTAMP)
    RETURNS VOID AS $$
    BEGIN
    INSERT INTO public.measurement_statistics (metric_id, time_bucket, time_start, average, inserted_at, updated_at)
    SELECT
        given_metric_id,
        given_time_bucket,
        given_time_start,
        AVG(value) AS average,
        CURRENT_TIMESTAMP AS inserted_at,
        CURRENT_TIMESTAMP AS updated_at
    FROM
        measurements
    WHERE
        measurements.metric_id = given_metric_id
        AND measurements.timestamp >= given_time_start
        AND measurements.timestamp < given_time_end
    ON CONFLICT (metric_id, time_bucket, time_start) DO UPDATE
    SET
        average = EXCLUDED.average,
        updated_at = EXCLUDED.updated_at;
    END;
    $$ LANGUAGE plpgsql;
    """

    drop_query = """
    DROP FUNCTION IF EXISTS update_measurement_statistics(metric_id bigint, time_unit time_bucket_type, time_start TIMESTAMP, time_end TIMESTAMP);
    """

    execute(create_query, drop_query)
  end

  defp create_cache_update_function do
    create_query = """
    CREATE OR REPLACE FUNCTION update_metrics_cache() RETURNS TRIGGER AS $$
    BEGIN
    PERFORM update_measurement_statistics(NEW.metric_id, 'minute', date_trunc('minute', NEW.timestamp), date_trunc('minute', NEW.timestamp) + INTERVAL '1 minute');
    PERFORM update_measurement_statistics(NEW.metric_id, 'hour', date_trunc('hour', NEW.timestamp), date_trunc('hour', NEW.timestamp) + INTERVAL '1 hour');
    PERFORM update_measurement_statistics(NEW.metric_id, 'day', date_trunc('day', NEW.timestamp), date_trunc('day', NEW.timestamp) + INTERVAL '1 day');

    RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    """

    drop_query = """
    DROP FUNCTION IF EXISTS update_metrics_cache();
    """

    execute(create_query, drop_query)
  end

  defp create_trigger do
    create_query = """
    CREATE TRIGGER update_metrics_cache_trigger
    AFTER INSERT OR UPDATE ON public.measurements
    FOR EACH ROW
    EXECUTE FUNCTION update_metrics_cache();
    """

    drop_query = """
    DROP TRIGGER IF EXISTS update_metrics_cache_trigger ON public.measurements;
    """

    execute(create_query, drop_query)
  end
end
