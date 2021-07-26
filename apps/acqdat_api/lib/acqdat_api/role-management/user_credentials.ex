defmodule AcqdatApi.RoleManagement.UserCredentials do
  import AcqdatApiWeb.Helpers
  alias Ecto.Multi
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.RoleManagement.{UserCredentials, UserSetting}

  defdelegate get(id), to: UserCredentials

  def update(cred, %{"user_setting" => user_settings, "id" => id} = params) do
    Multi.new()
    |> Multi.run(:update_credentials, fn _, _ ->
      UserCredentials.update(cred, params)
    end)
    |> Multi.run(:update_settings, fn _, %{update_credentials: cred} ->
      if cred.user_setting != nil do
        UserSetting.update(cred.user_setting, user_settings)
      else
        user_settings = Map.put_new(user_settings, "user_credentials_id", cred.id)
        UserSetting.create(user_settings)
      end
    end)
    |> run_transaction()
  end

  def update(cred, params) do
    UserCredentials.update(cred, params)
  end

  defp run_transaction(multi_query) do
    result = Repo.transaction(multi_query)

    case result do
      {:ok, %{update_credentials: cred, update_settings: _}} ->
        verify_credentials({:ok, cred})

      {:error, failed_operation, failed_value, _} ->
        case failed_operation do
          :update_credentials -> verify_error_changeset({:error, failed_value})
          :update_settings -> verify_error_changeset({:error, failed_value})
        end
    end
  end

  defp verify_credentials({:ok, cred}) do
    UserCredentials.get(cred.id)
  end

  defp verify_credentials({:error, cred}) do
    {:error, %{error: extract_changeset_error(cred)}}
  end

  defp verify_error_changeset({:error, changeset}) do
    {:error, %{error: extract_changeset_error(changeset)}}
  end
end
