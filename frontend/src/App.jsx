import React, { useState, useEffect } from 'react';
import MeasurementForm from './components/MeasurementForm';
import Graphs from './components/Graphs';
import { fetchMeasurementStatistics, postMeasurement } from './api';
import { Toaster } from 'react-hot-toast';

function App() {
  const [statistics, setStatistics] = useState(null);

  useEffect(() => {
    async function fetchData() {
      const data = await fetchMeasurementStatistics();
      setStatistics(data);
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
    <div>
      <Toaster />
      <Graphs statistics={statistics} />
      <MeasurementForm onSubmit={handleSubmit} />
    </div>
  );
}

export default App;
