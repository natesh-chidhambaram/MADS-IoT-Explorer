defmodule AcqdatCore.Model.RoleManagement.UserGroup do
  @moduledoc """
  Exposes APIs for handling groups.
  """
  import Ecto.Query
  alias AcqdatCore.Schema.RoleManagement.UserGroup
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.Helper, as: ModelHelper

  def create(params) do
    changeset = UserGroup.changeset(%UserGroup{}, params)
    Repo.insert(changeset)
  end

  def extract_groups(ids) do
    query =
      from(group in UserGroup,
        where: group.id in ^ids,
        select: group.id
      )

    Repo.all(query)
  end

  def get_all(%{page_size: page_size, page_number: page_number, org_id: org_id}, preloads) do
    query =
      from(user_group in UserGroup,
        where: user_group.org_id == ^org_id
      )

    paginated_user_group_data =
      query |> order_by(:id) |> Repo.paginate(page: page_number, page_size: page_size)

    user_group_data_with_preloads = paginated_user_group_data.entries |> Repo.preload(preloads)

    ModelHelper.paginated_response(user_group_data_with_preloads, paginated_user_group_data)
  end
end
