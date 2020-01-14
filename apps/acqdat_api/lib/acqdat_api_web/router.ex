defmodule AcqdatApiWeb.Router do
  use AcqdatApiWeb, :router

  if Mix.env() == :dev do
    # If using Phoenix
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  pipeline :api_bearer_auth do
    plug AcqdatApiWeb.BearerAuthPipeline
  end

  pipeline :api_ensure_auth do
    plug AcqdatApiWeb.EnsureAuthPipeline
  end

  pipeline :api do
    plug :accepts, ["json", "json-api"]
  end

  scope "/", AcqdatApiWeb do
    pipe_through :api
    post "/sign-in", AuthController, :sign_in
  end

  scope "/", AcqdatApiWeb do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]
    post "/refresh", AuthController, :refresh_token
    post "/sign-out", AuthController, :sign_out
    post "/search-location", PlaceController, :search_location

    resources "/sensor_type", SensorTypeController,
      only: [:create, :update, :delete, :index, :show]

    resources "/device", DeviceController, only: [:create, :update, :delete, :index, :show]
    get "/sensor-criteria/:device_id", SensorController, :sensor_by_criteria
    get "/device-criteria/:site_id", DeviceController, :device_by_criteria
    resources "/sensor", SensorController, only: [:create, :update, :delete, :index, :show]
    resources "/site", SiteController, only: [:create, :update, :delete, :index, :show]
    resources "/process", ProcessController, only: [:create, :update, :delete, :index, :show]

    resources "/digital-twin", DigitalTwinController,
      only: [:create, :update, :delete, :index, :show]

    resources "/policies", NotificationPolicyController, only: [:index]

    resources "/sensor_notification", SensorNotificationController,
      only: [:create, :update, :delete, :index, :show]
  end

  scope "/tl-mgmt", AcqdatApiWeb do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]
    post("/employee/identify", ToolManagementController, :verify_employee)
    post("/tool-transaction", ToolManagementController, :tool_transaction)
    post("/employees", ToolManagementController, :list_employees)
    post("/verify-tool", ToolManagementController, :verify_tool)
    post("/employee-tool-issue-status", ToolManagementController, :employee_tool_issue_status)
    post("/tool-box-status", ToolManagementController, :tool_box_status)

    scope "/", ToolManagement do
      resources "/employee", EmployeeController, only: [:create, :update, :delete, :index, :show]
      resources "/tool-box", ToolBoxController, only: [:create, :update, :delete, :index, :show]
      resources "/tools", ToolController, only: [:create, :update, :delete, :index, :show]
      resources "/tool-type", ToolTypeController, only: [:create, :update, :delete, :index, :show]
    end
  end
end
