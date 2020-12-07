defmodule AcqdatApi.ExtractRoutes do
  alias AcqdatApiWeb.Router

  #   "DashboardManagement" => %{
  #     "DashboardExport" => {
  #       "controller" => "DashboardExportController",
  #       "actions" => {
  #           "export" => %{path: :export, request_type: :get},
  #           "show" => %{path: :show, request_type: :get}
  #       }
  #     }
  #  }
  def extract_routes() do
    routes = Router.__routes__()

    Enum.reduce(routes, %{}, fn route, acc ->
      create_map(route, acc)
    end)
  end

  defp create_map(%{plug: controller_name, verb: request_type, plug_opts: action}, acc) do
    [feature, controller_name, trunc_controller] =
      controller_name |> to_string |> String.split(".") |> truncate_controller

    case Map.has_key?(acc, feature) do
      true ->
        add_feature_in_existing(acc, [
          feature,
          controller_name,
          trunc_controller,
          request_type,
          action
        ])

      false ->
        add_feature(acc, [feature, controller_name, trunc_controller, request_type, action])
    end
  end

  defp add_feature(acc, [feature, controller_name, trunc_controller, request_type, action]) do
    actions = %{} |> Map.put_new(action, %{path: action, request_type: request_type})

    inside_feature =
      %{} |> Map.put_new(:actions, actions) |> Map.put_new(:controller, controller_name)

    final_struct = %{} |> Map.put_new(trunc_controller, inside_feature)
    Map.put_new(acc, feature, final_struct)
  end

  defp add_feature_in_existing(acc, [
         feature,
         controller_name,
         trunc_controller,
         request_type,
         action
       ]) do
    final_struct = Map.fetch!(acc, feature)

    case Map.has_key?(final_struct, trunc_controller) do
      true ->
        inside_feature = Map.fetch!(final_struct, trunc_controller)
        current_actions = inside_feature.actions

        actions =
          current_actions |> Map.put_new(action, %{path: action, request_type: request_type})

        inside_feature = inside_feature |> Map.replace!(:actions, actions)
        final_struct = final_struct |> Map.replace!(trunc_controller, inside_feature)
        Map.replace!(acc, feature, final_struct)

      false ->
        actions = %{} |> Map.put_new(action, %{path: action, request_type: request_type})

        inside_feature =
          %{} |> Map.put_new(:actions, actions) |> Map.put_new(:controller, controller_name)

        final_struct = final_struct |> Map.put_new(trunc_controller, inside_feature)
        Map.replace!(acc, feature, final_struct)
    end
  end

  defp truncate_controller([_, _, feature, controller_name]) do
    [trunc_controller, _] = controller_name |> String.split("Controller") |> return_trunc
    [feature, controller_name, trunc_controller]
  end

  defp truncate_controller([_, feature, controller_name]) do
    [trunc_controller, _] = controller_name |> String.split("Controller") |> return_trunc
    [feature, controller_name, trunc_controller]
  end

  defp return_trunc([trunc_name, _]) do
    [trunc_name, nil]
  end

  defp return_trunc([trunc_name]) do
    [trunc_name, nil]
  end
end
