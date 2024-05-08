defmodule MeasureeWeb.Router do
  use MeasureeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MeasureeWeb do
    pipe_through :api

    resources "/metrics", MetricController, only: [:index]
    resources "/measurements", MeasurementController, only: [:index, :create, :show]
    resources "/measurement_statitics", MeasurementStatisticController, only: [:index]
  end
end
