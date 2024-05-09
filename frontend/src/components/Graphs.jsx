import Graph from "./Graph";

function Graphs({ statistics, metrics }) {
  if (!statistics || metrics.length == 0) return <div>Loading...</div>;

  return (
    <section id="graphs">
      <Graph title="Day" statistics={statistics.day} metrics={metrics} />
      <Graph title="Hour" statistics={statistics.hour} metrics={metrics} />
      <Graph title="Minute" statistics={statistics.minute} metrics={metrics} />
    </section>
  );
}

export default Graphs;
