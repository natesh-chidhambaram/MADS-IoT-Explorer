defmodule AcqdatApi.Widgets.User do
  alias AcqdatCore.Model.Widgets.User, as: UserModel
  alias AcqdatCore.Repo
  import AcqdatApiWeb.Helpers

  def create(params) do
    %{
      widget_id: widget_id,
      user_id: user_id
    } = params

    verify_user_widget(
      UserModel.create(%{
        widget_id: widget_id,
        user_id: user_id
      })
    )
  end

  defp verify_user_widget({:ok, user_widget}) do
    user_widget = user_widget |> Repo.preload([:user, widget: :widget_type])

    {:ok,
     %{
       id: user_widget.id,
       widget_id: user_widget.widget_id,
       user_id: user_widget.user_id,
       widget: user_widget.widget,
       user: user_widget.user
     }}
  end

  defp verify_user_widget({:error, message}) do
    {:error, %{error: extract_changeset_error(message)}}
  end
end
