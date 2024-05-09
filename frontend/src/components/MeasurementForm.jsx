import { useState } from 'react';
import toast from 'react-hot-toast';

function MeasurementForm({ onSubmit, metrics }) {
  // Slice to remove seconds and milliseconds
  const now = new Date();
  const currentTimeString = now.toISOString().slice(0, 16);
  const [formData, setFormData] = useState({
    metric_id: '',
    value: '',
    timestamp: currentTimeString,
  });
  const [error, setError] = useState(null);
  // loading and submitting state
  // disable submit button when in submitting state

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setError(null);
      await onSubmit(formData);
      toast.success("Measurement submitted successfully!")

      // Clear value after submission, keep metric and timestamp as likely to be used again
      setFormData({
        value: '',
        metric: formData.metric_id,
        timestamp: formData.timestamp
      });

    } catch (error) {
      toast.error("Oh noes! Form submit failed!")
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
