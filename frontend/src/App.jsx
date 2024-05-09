import { useState, useEffect, Fragment } from 'react';
import MeasurementForm from './components/MeasurementForm';
import Graphs from './components/Graphs';
import { fetchMeasurementStatistics, fetchMetrics, postMeasurement } from './api';
import toast, { Toaster } from 'react-hot-toast';

function App() {
  const [statistics, setStatistics] = useState(null);
  const [metrics, setMetrics] = useState([]);


  useEffect(() => {
    async function fetchData() {
      try {
        const statistics = await fetchMeasurementStatistics();
        const metrics = await fetchMetrics();

        setStatistics(statistics);
        setMetrics(metrics);
      } catch (error) {
        toast.error("Oops! Fetching data failed: " + error.message)
      }
    }

    fetchData();
  }, []);

  const handleSubmit = async (formData) => {
    try {
      await postMeasurement(formData);
      // Refresh statistics after submitting a new measurement
      const updatedStatistics = await fetchMeasurementStatistics();
      setStatistics(updatedStatistics);
    } catch (error) {
      toast.error("Oops! Fetching data failed: " + error.message)
    }
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
