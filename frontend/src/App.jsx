import React, { useState, useEffect, Fragment } from 'react';
import MeasurementForm from './components/MeasurementForm';
import Graphs from './components/Graphs';
import { fetchMeasurementStatistics, fetchMetrics, postMeasurement } from './api';
import { Toaster } from 'react-hot-toast';

function App() {
  const [statistics, setStatistics] = useState(null);
  const [metrics, setMetrics] = useState([]);


  useEffect(() => {
    async function fetchData() {
      const statistics = await fetchMeasurementStatistics();
      const metrics = await fetchMetrics();

      setStatistics(statistics);
      setMetrics(metrics);
    }
    fetchData();
  }, []);

  const handleSubmit = async (formData) => {
    await postMeasurement(formData);
    // Refresh statistics after submitting a new measurement
    const updatedStatistics = await fetchMeasurementStatistics();
    setStatistics(updatedStatistics);
  };

  return (
    <Fragment>
      <h1>Welcome to Measuree!</h1>
      <Toaster />
      <Graphs statistics={statistics} metrics={metrics} />
      <MeasurementForm onSubmit={handleSubmit} metrics={metrics} />
    </Fragment>
  );
}

export default App;
