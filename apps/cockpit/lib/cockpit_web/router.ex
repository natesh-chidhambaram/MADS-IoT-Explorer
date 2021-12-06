defmodule CockpitWeb.Router do
  use CockpitWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CockpitWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api/v1/", CockpitWeb do
    pipe_through :api

    post "/sign-up", AuthController, :registration
    post "/sign-in", AuthController, :login
    post "/forgot-password", AuthController, :forgot_password
  end

  # Other scopes may use custom stacks.
  # scope "/api", CockpitWeb do
  #   pipe_through :api
  # end
end
