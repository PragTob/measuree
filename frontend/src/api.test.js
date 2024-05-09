import {
  fetchMetrics,
  fetchMeasurementStatistics,
  postMeasurement,
} from "./api";

describe("API Client", () => {
  beforeEach(() => {
    jest.spyOn(global, "fetch").mockClear();
    jest.spyOn(console, "error").mockImplementation(jest.fn());
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe("fetchMetrics", () => {
    test("success", async () => {
      const mockData = [
        { id: 1, name: "Metric 1" },
        { id: 2, name: "Metric 2" },
      ];
      global.fetch = jest.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ data: mockData }),
      });

      const metrics = await fetchMetrics();

      expect(metrics).toEqual(mockData);
      expect(global.fetch).toHaveBeenCalledWith(
        "http://localhost:4000/api/metrics",
      );
    });

    test("failure", async () => {
      global.fetch = jest.fn().mockResolvedValue({ ok: false });

      await expect(fetchMetrics()).rejects.toThrow("Failed to fetch metrics");
    });
  });

  describe("fetchMeasurementStatistics", () => {
    test("success", async () => {
      const mockData = [{ metric_id: 1, average: 34.77 }];
      global.fetch = jest.fn().mockResolvedValue({
        ok: true,
        json: () => Promise.resolve({ data: mockData }),
      });

      const statistics = await fetchMeasurementStatistics();

      expect(statistics).toEqual(mockData);
      expect(global.fetch).toHaveBeenCalledWith(
        "http://localhost:4000/api/measurement_statistics",
      );
    });

    test("failure", async () => {
      global.fetch = jest.fn().mockResolvedValue({ ok: false });

      await expect(fetchMeasurementStatistics()).rejects.toThrow(
        "Failed to fetch measurement statistics",
      );
    });
  });

  describe("postMeasurement", () => {
    test("success", async () => {
      const mockData = {};
      global.fetch = jest.fn().mockResolvedValue({ ok: true });

      await postMeasurement(mockData);

      expect(global.fetch).toHaveBeenCalledWith(
        "http://localhost:4000/api/measurements",
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ measurement: mockData }),
        },
      );
    });

    test("general failure", async () => {
      const mockData = {};
      global.fetch = jest.fn().mockResolvedValue({ ok: false });

      await expect(postMeasurement(mockData)).rejects.toThrow(
        "Failed to post measurement",
      );
    });

    test("unprocessable entity but no errors", async () => {
      const mockData = {};
      global.fetch = jest.fn().mockResolvedValue({
        ok: false,
        status: 422,
        json: () => Promise.resolve({}),
      });

      await expect(postMeasurement(mockData)).rejects.toThrow(
        "Unprocessable Entity",
      );
    });

    test("unprocessable error but nice validation error", async () => {
      const mockData = {};
      const responseBody = {
        errors: {
          value: ["can't be blank"],
          metric_id: ["can't be blank", "other error"],
        },
      };

      global.fetch = jest.fn().mockResolvedValue({
        ok: false,
        status: 422,
        json: () => Promise.resolve(responseBody),
      });

      await expect(postMeasurement(mockData)).rejects.toThrow(
        "Encountered errors:\nvalue: can't be blank\nmetric_id: can't be blank, other error\n",
      );
    });
  });
});
