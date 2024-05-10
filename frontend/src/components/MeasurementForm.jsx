import { useState } from "react";
import toast from "react-hot-toast";
import { postMeasurement } from "./../api";

function MeasurementForm({ onSubmit, metrics }) {
  const now = new Date();
  // Slice to remove seconds and milliseconds
  const currentTimeString = now.toISOString().slice(0, 16);
  const [formData, setFormData] = useState({
    metric_id: "",
    value: "",
    timestamp: currentTimeString,
  });
  const [error, setError] = useState(null);
  const [submitting, setSubmitting] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setSubmitting(true);
      setError(null);
      await postMeasurement(formData);
      setSubmitting(false);
      toast.success("Measurement submitted successfully!");

      // Clear value after submission, keep metric and timestamp as likely to be used again
      setFormData({
        value: "",
        metric_id: formData.metric_id,
        timestamp: formData.timestamp,
      });

      onSubmit();
    } catch (error) {
      toast.error("Oops! Submitting the form failed!:\n" + error.message);

      setSubmitting(false);
      setError(error.message);
    }
  };

  return (
    <form onSubmit={handleSubmit} role="form">
      <h2>Submit New Measurement</h2>
      {error && <div style={{ color: "red" }}>{error}</div>}
      {submitting && <div>Submitting...</div>}

      <label>
        Metric Name:
        <select
          name="metric_id"
          value={formData.metric_id}
          onChange={handleChange}
        >
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
        <input
          type="number"
          step="0.01"
          name="value"
          value={formData.value}
          onChange={handleChange}
        />
      </label>
      <label>
        Timestamp:
        <input
          type="datetime-local"
          name="timestamp"
          value={formData.timestamp}
          onChange={handleChange}
        />
      </label>
      <button
        className="success-button"
        style={{ marginTop: "10px" }}
        type="submit"
        disabled={submitting}
      >
        Submit
      </button>
    </form>
  );
}

export default MeasurementForm;
