import React from 'react';
import Graph from './Graph';

function Graphs({ statistics }) {
  if (!statistics) return <div>Loading...</div>;

  return (
    <div>
      <Graph title="Minute" statistics={statistics.minute} />
      <Graph title="Hour" statistics={statistics.hour} />
      <Graph title="Day" statistics={statistics.day} />
    </div>
  );
}

export default Graphs;
