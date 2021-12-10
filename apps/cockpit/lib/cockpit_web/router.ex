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

  pipeline :reset_password_auth do
    plug(CockpitWeb.ResetPasswordAuth)
  end

  scope "/", CockpitWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api/v1/", CockpitWeb do
    pipe_through :api

    post "/sign-up", AuthController, :registration
    post "/sign-in", AuthController, :sign_in
    post "/forgot-password", AuthController, :forgot_password
  end

  scope "/", CockpitWeb do
    pipe_through [:api, :reset_password_auth]
    put "/reset_password", AuthController, :reset_password
  end

end
