defmodule AcqdatCore.Model.Widgets.User do
  alias AcqdatCore.Widgets.Schema.UserWidgets, as: User
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.Helper, as: ModelHelper
  import Ecto.Query

  def create(params) do
    changeset = User.changeset(%User{}, params)
    Repo.insert(changeset)
  end

  def get(id) when is_integer(id) do
    case Repo.get(User, id) do
      nil ->
        {:error, "not found"}

      user ->
        {:ok, user |> Repo.preload([:user, :widget])}
    end
  end

  def delete(user) do
    Repo.delete(user)
  end

  # TODO
  # def update(user, params) do
  #   changeset = User.update_changeset(user, params)
  #   Repo.update(changeset)
  # end

  def get_all(%{page_size: page_size, page_number: page_number}) do
    User
    |> order_by(:id)
    |> Repo.paginate(page: page_number, page_size: page_size)
  end

  def get_all(%{page_size: page_size, page_number: page_number, user_id: user_id}, preloads) do
    query =
      from(user_widget in User,
        where: user_widget.user_id == ^user_id,
        order_by: [asc: user_widget.id]
      )

    paginated_user_data = query |> Repo.paginate(page: page_number, page_size: page_size)

    user_data_with_preloads = paginated_user_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(user_data_with_preloads, paginated_user_data)
  end
end
