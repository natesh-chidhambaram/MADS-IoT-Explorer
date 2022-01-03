defmodule AcqdatApi.ResourceManagement.ShareResource do
  @moduledoc """
  Module to handle resource sharing logic.
  """
  alias AcqdatCore.Cockpit.Models.ShareResource
  alias AcqdatCore.Cockpit.Models.User

  def share(data, current_user_id) do
    Enum.each(data.share_with, fn email ->
      email
      |> User.get_user_by_email()
      |> verfiy_and_get_user(email)
      |> share_resource_with_user(data, current_user_id)
    end)

    {:ok, :shared}
  end

  defp verfiy_and_get_user(nil, email), do: email |> User.initiate() |> elem(1)
  defp verfiy_and_get_user(user, _email), do: user

  defp share_resource_with_user(
         cockpit_user,
         %{
           org_id: org_id,
           resource_id: resource_id,
           resource_type: resource_type
         },
         current_user_id
       ) do
    params = %{
      type: convert_resource_to_code(resource_type),
      resource_id: String.to_integer(resource_id),
      org_id: String.to_integer(org_id),
      share_by_id: current_user_id,
      cockpit_user_id: cockpit_user.id
    }

    ShareResource.share_resource(params)
  end

  defp convert_resource_to_code("dashboard"), do: 1
  defp convert_resource_to_code("reports"), do: 2
end
