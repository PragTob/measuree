defmodule MeasureeWeb.Router do
  use MeasureeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    # grml SPA allow access
    plug CORSPlug, origin: ["http://localhost:5173"]
  end

  scope "/api", MeasureeWeb do
    pipe_through :api

    resources "/metrics", MetricController, only: [:index]
    resources "/measurements", MeasurementController, only: [:index, :create, :show]
    resources "/measurement_statistics", MeasurementStatisticController, only: [:index]
  end
end
