defmodule AcqdatIotWeb.Router do
  use AcqdatIotWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AcqdatIotWeb do
    pipe_through :api
  end
end
