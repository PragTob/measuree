import React from 'react';

import Plot from 'react-plotly.js';

function Graph({ title, statistics, metrics }) {

  const metricIdToName = metrics.reduce((map, metric) => {
    map[metric.id] = metric.name;
    return map;
  }, {});

  const graphData = Object.entries(statistics).map(([metricId, data]) => (
    {
      x: data.map(stat => stat.time_start),
      y: data.map(stat => stat.average),
      type: 'scatter',
      mode: 'lines+markers',
      name: metricIdToName[metricId]
    }
  ))

  return (
    <div>
      <h2>{title}</h2>

      <Plot
        data={graphData}
        layout={{
          width: 1200,
          height: 800,
          title: title,
          xaxis: {
            title: "Time"
          },
          yaxis: {
            title: "Value"
          }
        }}
        config={{ displaylogo: false }}
      />
    </div>
  );
}

export default Graph;
