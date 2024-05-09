import React, { useState, useEffect } from 'react';
import { fetchMetrics } from './../api';
import toast from 'react-hot-toast';

function MeasurementForm({ onSubmit }) {
  const [formData, setFormData] = useState({
    metric_id: '',
    value: '',
    timestamp: '',
  });
  const [error, setError] = useState(null);
  const [metrics, setMetrics] = useState([]);
  // loading and submitting state

  useEffect(() => {
    async function fetchMetricsData() {
      const data = await fetchMetrics();
      if (data) {
        setMetrics(data);
      }
    }
    fetchMetricsData();
  }, []);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setError(null);
      await onSubmit(formData);
      // Clear form fields after successful submission
      toast.success("Measurement submitted successfully!")
      setFormData({
        metric_id: '',
        value: '',
        timestamp: '',
      });
    } catch (error) {
      setError(error.message);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <h2>Submit New Measurement</h2>
      {error && <div style={{ color: 'red' }}>{error}</div>}
      <label>
        Metric Name:
        <select name="metric_id" value={formData.metric_id} onChange={handleChange}>
          <option value="">Select a Metric</option>
          {metrics.map((metric) => (
            <option key={metric.id} value={metric.id}>
              {metric.name}
            </option>
          ))}
        </select>
      </label>
      <label>
        Value:
        <input type="number" step="0.01" name="value" value={formData.value} onChange={handleChange} />
      </label>
      <label>
        Timestamp:
        <input type="datetime-local" name="timestamp" value={formData.timestamp} onChange={handleChange} />
      </label>
      <button type="submit">Submit</button>
    </form>
  );
}

export default MeasurementForm;
