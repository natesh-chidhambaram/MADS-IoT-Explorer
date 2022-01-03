defmodule AcqdatCore.Cockpit.Models.ShareResource do
  @moduledoc """
  Service module to perform database CRUD operations for cockpit users.
  """

  alias AcqdatCore.Repo
  alias AcqdatCore.Cockpit.Schemas.ShareResource

  def share_resource(params) do
    %ShareResource{}
    |> ShareResource.share_changeset(params)
    |> Repo.insert()
  end
end
