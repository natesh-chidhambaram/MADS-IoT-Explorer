defmodule AcqdatApiWeb.Router do
  use AcqdatApiWeb, :router
  use Plug.ErrorHandler

  if Mix.env() == :dev do
    # If using Phoenix
    forward("/sent_emails", Bamboo.SentEmailViewerPlug)
  end

  pipeline :api_bearer_auth do
    plug(AcqdatApiWeb.BearerAuthPipeline)
  end

  pipeline :api_ensure_auth do
    plug(AcqdatApiWeb.EnsureAuthPipeline)
  end

  pipeline :api do
    plug(:accepts, ["json", "json-api"])
  end

  pipeline :export_auth do
    plug(AcqdatApiWeb.DashboardExportAuth)
  end

  pipeline :password_reset_auth do
    plug(AcqdatApiWeb.PasswordResetAuth)
  end

  scope "/", AcqdatApiWeb do
    pipe_through(:password_reset_auth)
    put("/reset_password", RoleManagement.ForgotPasswordController, :reset_password)
  end

  scope "/", AcqdatApiWeb do
    pipe_through(:api)
    post "/verify-token", RoleManagement.InvitationController, :validate_token
    post("/sign-in", AuthController, :sign_in)
    post("/orgs/:org_id/sign-in", AuthController, :org_sign_in)
    post("/sign-up", AuthController, :register)
    post("/forgot_password", RoleManagement.ForgotPasswordController, :forgot_password)
    post("/orgs/:org_id/users", RoleManagement.UserController, :create)

    post("/validate_org_url", EntityManagement.OrganisationController, :validate_org_url)
  end

  scope "/", AcqdatApiWeb do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]

    scope "/orgs/:org_id", RoleManagement do
      resources "/users", UserController, only: [:show, :update, :index, :delete] do
        resources "/settings", UserSettingController,
          only: [:create, :update],
          as: :settings
      end
    end

    post "/validate-token", AuthController, :validate_token
    post "/sign-out", AuthController, :sign_out
    post "/orgs/:org_id/validate_credentials", AuthController, :validate_credentials

    resources "/orgs", EntityManagement.OrganisationController,
      only: [:show, :create, :index, :update, :delete]

    resources "/apps", AppController, only: [:index]
    get("/orgs/:id/apps", EntityManagement.OrganisationController, :get_apps, as: :org_apps)

    resources("/digital-twin", DigitalTwinController,
      only: [:create, :update, :delete, :index, :show]
    )

    resources "/user_credentials", RoleManagement.UserCredentialsController,
      only: [:show, :update]

    resources "/uploads", ImageUploadController, only: [:create]
  end

  # NOTE: Please add resources here, only if they needs to be scoped by organisation
  scope "/orgs/:org_id", AcqdatApiWeb do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]
    get("/entities", EntityManagement.EntityController, :fetch_all_hierarchy)
  end

  ####################### IoT Manager ########################

  scope "/iot_mgmt", AcqdatApiWeb do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]

    scope "/orgs/:org_id" do
      get "/projects/:project_id/gateways/mapped_sensors",
          IotManager.GatewayController,
          :mapped_sensors,
          as: :mapped_sensors

      get("/entities", EntityManagement.EntityController, :fetch_all_hierarchy)

      get("/projects/search", EntityManagement.ProjectController, :search_projects,
        as: :search_projects
      )

      resources "/users", RoleManagement.UserController, only: [:show, :update, :index, :delete]

      get "/projects", IotManager.GatewayController, :fetch_projects
      get "/gateways/", IotManager.GatewayController, :all_gateways

      scope "/projects/:project_id", IotManager do
        get "/entities", GatewayController, :fetch_project_tree
        get "/gateways/search", GatewayController, :search_gateways, as: :search_gateways
        put "/gateways/:gateway_id/associate-sensors", GatewayController, :associate_sensors
        resources "/gateways", GatewayController, except: [:new, :edit]
        post "/gateways/:gateway_id/store_commands", GatewayController, :store_commands
        get("/hierarchy", GatewayController, :hierarchy)
        get("/gateway_data/:gateway_id", DataController, :gateway_data)
        delete("/gateway_data_delete", DataController, :gateway_data_delete)
        get "/gateways/:gateway_id/data_dump_index", GatewayController, :data_dump_index

        get "/gateways/:gateway_id/data_dump_error_index",
            GatewayController,
            :data_dump_error_index

        delete "/gateways/:gateway_id/delete_data_dump", GatewayController, :delete_data_dump
      end

      scope "/", Alerts do
        resources "/policies", PolicyController, only: [:index]
        get "/grouping_rules", AlertRulesController, :grouping_rules
        resources "/alert-rules", AlertRulesController, except: [:new, :edit]
        get "/alert_rule_listing", AlertFilterListingController, :alert_rule_listing
        get "/alert_apps", AlertFilterListingController, :alert_app_listing
        get "/alert_status", AlertFilterListingController, :alert_status_listing
      end
    end
  end

  ################### Dashboard management ############################

  scope "/dash_mgmt", AcqdatApiWeb.DashboardManagement do
    scope "/" do
      pipe_through [:api, :api_bearer_auth, :api_ensure_auth]

      scope "/orgs/:org_id" do
        post(
          "/dashboards/:dashboard_id/export",
          DashboardExportController,
          :create
        )

        put(
          "/dashboards/:dashboard_id/export/:dashboard_uuid",
          DashboardExportController,
          :update
        )

        get(
          "/dashboards/:dashboard_id/export/:dashboard_uuid/show_credentials",
          DashboardExportController,
          :show_credentials
        )

        post("/fetch_token", DashboardController, :fetch_token)
        resources "/dashboards", DashboardController, except: [:new, :edit]
        get "/recent_dashboards", DashboardController, :recent_dashboard
        post "/dashboards/:id/reports", DashboardController, :reports

        scope "/dashboards/:dashboard_id" do
          resources "/panels", PanelController, except: [:new, :edit]
        end

        scope "/panels/:panel_id" do
          resources "/command_widgets", CommandWidgetController, except: [:new, :index, :edit]
        end

        get "/command_widget_types",
            CommandWidgetController,
            :command_widget_types

        post "/panels/:panel_id/widgets/:widget_id/widget_instances",
             WidgetInstanceController,
             :create,
             as: :create_widget_instances

        get "/panels/:panel_id/widgets/:widget_id/widget_instances/:id",
            WidgetInstanceController,
            :show,
            as: :show_widget_instances

        delete "/panels/:panel_id/widgets/:widget_id/widget_instances/:id",
               WidgetInstanceController,
               :delete,
               as: :delete_widget_instances

        put "/panels/:panel_id/widgets/:widget_id/widget_instances/:id",
            WidgetInstanceController,
            :update,
            as: :update_widget_instances

        get("/entities", DashboardController, :fetch_all_hierarchy)
        get("/gateways/", DashboardController, :all_gateways)
      end

      get("/widgets/filtered", DashboardController, :fetch_widgets)
      resources "/widgets", WidgetController, only: [:show]
    end

    scope "/" do
      pipe_through(:export_auth)
      get("/dashboards/:dashboard_uuid", DashboardExportController, :export)

      get(
        "/dashboards/:dashboard_uuid/verify",
        DashboardExportController,
        :exported_dashboard
      )

      post(
        "/details/:dashboard_uuid/panels/:id",
        DashboardExportController,
        :show
      )

      get(
        "/dashboards/:dashboard_uuid/panels/:panel_id/widget_instances/:id",
        DashboardExportController,
        :fetch_widget_instances
      )

      post "/dashboards/:dashboard_uuid/reports",
           DashboardExportController,
           :reports

      get "/orgs/:org_id/dashboards/:dashboard_uuid/hierarchy",
          DashboardExportController,
          :fetch_all_hierarchy
    end
  end

  ################### Entity management ############################

  scope "/enty_mgmt", AcqdatApiWeb.EntityManagement do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]

    scope "/orgs/:org_id" do
      get("/projects/search", ProjectController, :search_projects, as: :search_projects)
      get("/archived_projects", ProjectController, :archived, as: :archived_projects)
      resources "/projects", ProjectController, only: [:index, :create, :update, :delete, :show]

      post("/projects/:project_id/entities", EntityController, :update_hierarchy)
      get("/projects/:project_id/entities", EntityController, :fetch_hierarchy)

      scope "/projects/:project_id" do
        get("/sensors_data/:sensor_id", SensorController, :sensors_data)
        delete("/sensor_data_delete", SensorController, :sensor_data_delete)
        resources "/asset_types", AssetTypeController, only: [:create, :update, :delete, :index]
        get "/assets/search", AssetController, :search_assets, as: :search_assets
        get "/sensors/search", SensorController, :search_sensors, as: :search_sensors

        get "/sensor_type/search", SensorTypeController, :search_sensor_type,
          as: :search_sensor_type

        get "/asset_types/search", AssetTypeController, :search_asset_type, as: :search_asset_type

        resources "/assets", AssetController,
          only: [:create, :show, :update, :delete, :index],
          as: :assets

        resources "/sensors", SensorController, except: [:new, :edit]
        resources "/sensor_type", SensorTypeController, only: [:create, :index, :delete, :update]
      end

      get("/projects/:project_id/users", ProjectController, :fetch_project_users)
    end

    post("/fetch-count", EntityController, :fetch_count)
  end

  ################### Data Insights ############################

  scope "/data_inst", AcqdatApiWeb do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]

    scope "/orgs/:org_id", DataInsights do
      get("/projects", TopologyController, :fetch_projects)

      scope "/projects/:project_id" do
        resources "/topology", TopologyController, only: [:index]
        get("/topology_entities", TopologyController, :entities)

        resources "/fact_tables", FactTablesController, except: [:new, :edit] do
          get("/details", FactTablesController, :details)
          get("/fetch_headers", FactTablesController, :fetch_headers)

          resources "/visualizations", VisualizationsController, except: [:new, :edit] do
            post("/export", VisualizationsController, :export)
          end
        end

        get("/visualizations/fetch_all_types", VisualizationsController, :fetch_all_types)
        get("/visualizations/:id/validate_widget", VisualizationsController, :validate_widget)
      end

      post("/fetch_token", EntityController, :fetch_token)
    end

    scope "/orgs/:org_id" do
      get("/projects/search", EntityManagement.ProjectController, :search_projects,
        as: :search_projects
      )
    end
  end

  ################### Data Cruncher ############################

  scope "/data_crhr", AcqdatApiWeb.DataCruncher do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]

    scope "/orgs/:org_id" do
      resources "/components", ComponentsController, only: [:index]
      post("/data_cruncher_token", EntityController, :fetch_token)
      get("/entities", EntityController, :fetch_all_hierarchy)

      scope "/users/:user_id" do
        resources "/tasks", TasksController, only: [:create, :index, :show, :update, :delete]
      end
    end
  end

  #################### Metrics ######################################
  scope "/metrics", AcqdatApiWeb.Metrics do
    scope "/" do
      pipe_through [:api, :api_bearer_auth, :api_ensure_auth]

      scope "/orgs/:org_id" do
        post("/reports", ReportsController, :create)
      end

      get "/sections", ReportsController, :fetch_headers
    end
  end

  ######################### Tenant Manager ############################
  scope "/tent_mgmt", AcqdatApiWeb do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]
    get "/apis", RoleManagement.ExtractedRoutesController, :apis

    scope "/", TenantManagement do
      get "/orgs", RequestsController, :org_index
      resources "/requests", RequestsController, only: [:update, :index]
    end

    resources "/orgs", EntityManagement.OrganisationController,
      only: [:show, :create, :index, :update, :delete]
  end

  ######################### Alerts ####################################
  scope "/alert", AcqdatApiWeb do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]

    scope "/orgs/:org_id", Alerts do
      get "/projects", AlertController, :fetch_projects
      resources "/policies", PolicyController, only: [:index]
      resources "/alert-rules", AlertRulesController, except: [:new, :edit]
      resources "/alert", AlertController, except: [:new, :edit, :create]
      get "/alert_rule_listing", AlertFilterListingController, :alert_rule_listing
      get "/alert_apps", AlertFilterListingController, :alert_app_listing
      get "/alert_status", AlertFilterListingController, :alert_status_listing
    end

    scope "/orgs/:org_id" do
      get("/projects/search", EntityManagement.ProjectController, :search_projects,
        as: :search_projects
      )
    end
  end

  ######################### Role Manager ####################################
  scope "/role_mgmt", AcqdatApiWeb do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]
    get "/apis", RoleManagement.ExtractedRoutesController, :apis

    scope "/orgs/:org_id", RoleManagement do
      resources "/projects", ProjectController, only: [:index, :create, :update, :delete]
      resources "/user_groups", UserGroupController, except: [:new, :edit]
      post "/group_policies", UserGroupController, :group_policies

      resources "/users", UserController, only: [:show, :update, :index, :delete] do
        resources "/settings", UserSettingController,
          only: [:create, :update],
          as: :settings
      end

      get("/projects/:project_id/users", ProjectController, :fetch_project_users)

      get("/projects/search", ProjectController, :search_projects,
        as: :role_management_search_projects
      )

      get("/archived_projects", ProjectController, :archived, as: :archived_projects)

      resources "/roles", RoleController, only: [:index]
      get "/search_users", UserController, :search_users
      put("/users/:id/assets", UserController, :assets, as: :user_assets)
      put("/users/:id/apps", UserController, :apps, as: :user_apps)
      resources "/invitations", InvitationController, only: [:create, :update, :index, :delete]
    end

    post("/fetch-count", RoleManagement.ProjectController, :fetch_count)
  end

  ######################### Widgets Manager ####################################
  scope "/wigt_mgmt", AcqdatApiWeb.Widgets do
    pipe_through [:api, :api_bearer_auth, :api_ensure_auth]

    # NOTE: Kept widgets resources out of organisation_scope currently
    get "/widgets/search", WidgetController, :search_widget

    get "/widgets/filtered", WidgetController, :fetch_all

    resources "/widgets", WidgetController, only: [:create, :update, :delete, :index, :show]

    resources "/widget-type", WidgetTypeController,
      only: [:create, :update, :delete, :index, :show]

    scope "/orgs/:org_id" do
      scope "/users/:user_id" do
        resources "/widgets", UserWidgetController, only: [:index, :create], as: :user_widgets
      end
    end
  end

  ######################### Tool Management ###########################
  # TODO: Need to remove this scope later, and clean test-cases also
  scope "/tl-mgmt", AcqdatApiWeb do
    pipe_through([:api, :api_bearer_auth, :api_ensure_auth])
    post("/employee/identify", ToolManagementController, :verify_employee)
    post("/tool-transaction", ToolManagementController, :tool_transaction)
    post("/employees", ToolManagementController, :list_employees)
    post("/verify-tool", ToolManagementController, :verify_tool)
    post("/employee-tool-issue-status", ToolManagementController, :employee_tool_issue_status)
    post("/tool-box-status", ToolManagementController, :tool_box_status)

    scope "/", ToolManagement do
      resources("/employee", EmployeeController, only: [:create, :update, :delete, :index, :show])
      resources("/tool-box", ToolBoxController, only: [:create, :update, :delete, :index, :show])
      resources("/tools", ToolController, only: [:create, :update, :delete, :index, :show])

      resources("/tool-type", ToolTypeController, only: [:create, :update, :delete, :index, :show])
    end
  end

   #################### Reports ######################################
   scope "/reports", AcqdatApiWeb.Reports do
    scope "/" do
      pipe_through [:api, :api_bearer_auth, :api_ensure_auth]

      get "/templates", TemplateController, :index
      # get "/reports", ReportsController, :index
    end
  end


end
