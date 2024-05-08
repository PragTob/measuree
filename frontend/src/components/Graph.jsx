import React from 'react';

import Plot from 'react-plotly.js';

function Graph({ title, statistics }) {

  const graphData = Object.entries(statistics).map(([metricId, data]) => (
    {
      x: data.map(stat => stat.time_start),
      y: data.map(stat => stat.average),
      type: 'scatter',
      mode: 'lines+markers',
      // TODO: get/look up name
      name: metricId
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
