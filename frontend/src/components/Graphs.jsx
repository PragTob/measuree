import Graph from "./Graph";

function Graphs({ statistics, metrics }) {
  if (!statistics || metrics.length == 0) return <div>Loading...</div>;

  return (
    <section id="graphs">
      <Graph
        title="Daily Averages"
        statistics={statistics.day}
        metrics={metrics}
      />
      <Graph
        title="Hourly Averages"
        statistics={statistics.hour}
        metrics={metrics}
      />
      <Graph
        title="Minute Averages"
        statistics={statistics.minute}
        metrics={metrics}
      />
    </section>
  );
}

export default Graphs;
