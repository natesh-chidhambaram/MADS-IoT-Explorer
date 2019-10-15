defmodule AcqdatApiWeb.Router do
  use AcqdatApiWeb, :router

  if Mix.env == :dev do
    # If using Phoenix
    forward "/sent_emails", Bamboo.SentEmailViewerPlug

    # If using Plug.Router, make sure to add the `to`
    forward "/sent_emails", to: Bamboo.SentEmailViewerPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AcqdatApiWeb do
    pipe_through :api
  end
end
