const BASE_URL = "http://localhost:4000/api";

export async function fetchMetrics() {
  try {
    const response = await fetch(`${BASE_URL}/metrics`);
    if (!response.ok) {
      throw new Error("Failed to fetch metrics");
    }
    const json = await response.json();

    return json.data;
  } catch (error) {
    console.error(error);
    throw error;
  }
}

export async function fetchMeasurementStatistics() {
  try {
    const response = await fetch(`${BASE_URL}/measurement_statistics`);
    if (!response.ok) {
      throw new Error("Failed to fetch measurement statistics");
    }
    const json = await response.json();

    return json.data;
  } catch (error) {
    console.error(error);
    throw error;
  }
}

function errorMessage(errorObject) {
  let errorMessage = "Encountered errors:\n";
  for (const [attribute, messages] of Object.entries(errorObject)) {
    errorMessage += `${attribute}: ${messages.join(", ")}\n`;
  }

  return errorMessage;
}

export async function postMeasurement(formData) {
  try {
    const response = await fetch(`${BASE_URL}/measurements`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ measurement: formData }),
    });
    if (!response.ok) {
      if (response.status === 422) {
        const responseBody = await response.json();
        if (responseBody.errors) {
          throw new Error(errorMessage(responseBody.errors));
        } else {
          throw new Error("Unprocessable Entity");
        }
      } else {
        throw new Error("Failed to post measurement");
      }
    }
    // make effect in UI
    console.log("Measurement posted successfully");
  } catch (error) {
    console.error(error);
    throw error;
  }
}
