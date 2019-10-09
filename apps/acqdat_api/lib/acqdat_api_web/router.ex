defmodule AcqdatApiWeb.Router do
  use AcqdatApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AcqdatApiWeb do
    pipe_through :api
  end
end
