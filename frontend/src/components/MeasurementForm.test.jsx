/**
 * @jest-environment jsdom
 */

import { render, fireEvent, waitFor, screen } from '@testing-library/react';
import '@testing-library/jest-dom'
import MeasurementForm from './MeasurementForm';

describe('MeasurementForm', () => {
  test('renders with initial values', () => {
    render(<MeasurementForm metrics={[]} />);

    expect(screen.getByLabelText('Metric Name:')).toHaveValue('');
    expect(screen.getByLabelText('Value:')).toHaveValue(null);

    // datetime-local values are weird
    const timestampInput = screen.getByLabelText('Timestamp:');
    const timestampValue = timestampInput.getAttribute('value');
    expect(timestampValue).toMatch(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}/);
  });

  test('submits form with valid data', async () => {
    const onSubmit = jest.fn();
    const metrics = [{ id: 1, name: 'Metric 1' }, { id: 2, name: 'Metric 2' }];
    render(<MeasurementForm onSubmit={onSubmit} metrics={metrics} />);

    const timestamp = '2024-05-10T19:43:22'
    const timestampWithPrecision = `${timestamp}.000`

    // Fill out the form
    fireEvent.change(screen.getByLabelText('Metric Name:'), { target: { value: '1' } });
    fireEvent.change(screen.getByLabelText('Value:'), { target: { value: '10' } });
    fireEvent.change(screen.getByLabelText('Timestamp:'), { target: { value: timestamp } });

    fireEvent.submit(screen.getByRole('form'));

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        metric_id: '1',
        value: '10',
        timestamp: timestampWithPrecision,
      });
    });

    // Assert that metric and timetsamp are kept
    expect(screen.getByLabelText('Metric Name:')).toHaveValue('1');
    expect(screen.getByLabelText('Timestamp:')).toHaveValue(timestampWithPrecision);

    // But value is cleared
    expect(screen.getByLabelText('Value:')).toHaveValue(null);
  });
});
