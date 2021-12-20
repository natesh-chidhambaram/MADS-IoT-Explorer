defmodule AcqdatCore.Model.DashboardManagement.Subpanel do
  import Ecto.Query
  alias AcqdatCore.DashboardManagement.Schema.Subpanel
  alias AcqdatCore.Model.DashboardManagement.CommandWidget
  alias AcqdatCore.Repo

  def create(params) do
    changeset = Subpanel.changeset(%Subpanel{}, params)
    Repo.insert(changeset)
  end

  def get_with_widgets(uuid) do
    case Repo.get_by(Subpanel, uuid: uuid) do
      nil ->
        {:error, "Subpanel with this id not found"}

      subpanel ->
        {:ok, subpanel}
    end
  end

  def get_all_subpanels(panel_id) do
    query = from(s in Subpanel, where: s.panel_id == ^panel_id)

    case Repo.all(query) do
      [] -> {:error, "No subpanel for this panel"}
      subpanels -> {:ok, subpanels}
    end
  end

  def update(subpanel, params) do
    changeset = Subpanel.update_changeset(subpanel, params)
    Repo.update(changeset)
  end

  def get_by_uuid(uuid) do
    case Repo.get_by(Subpanel, uuid: uuid) do
      nil -> {:error, "Subpanel with this id not found"}
      subpanel -> {:ok, subpanel}
    end
  end

  def delete(subpanel) do
    Repo.delete(subpanel)
  end
end
