defmodule AcqdatCore.Model.RoleManagement.Invitation do
  @moduledoc """
  Exposes APIs for handling user related fields.
  """

  alias AcqdatCore.Schema.RoleManagement.Invitation
  alias AcqdatCore.Repo
  alias AcqdatCore.Model.Helper, as: ModelHelper
  alias AcqdatCore.Model.RoleManagement.User
  import Ecto.Query

  def list_invitations() do
    Repo.all(Invitation)
  end

  def return_count(%{"type" => "UserInvite", "org_id" => org_id}) do
    query =
      from(p in Invitation,
        where: p.org_id == ^org_id,
        select: count(p.id)
      )

    Repo.one(query)
  end

  def return_count(%{"type" => "UserInvite"}) do
    query =
      from(p in Invitation,
        select: count(p.id)
      )

    Repo.one(query)
  end

  def create_invitation(attrs \\ %{}) do
    %Invitation{}
    |> Invitation.changeset(attrs)
    |> Repo.insert()
  end

  def update_invitation(%Invitation{} = invitation, attrs \\ %{}) do
    invitation
    |> Invitation.update_changeset(attrs)
    |> Repo.update()
  end

  def update_invitation_token(%Invitation{} = invitation, attrs \\ %{}) do
    invitation
    |> Invitation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns a invitation by the supplied id.
  """
  def get(id) when is_integer(id) do
    case Repo.get(Invitation, id) do
      nil ->
        {:error, "not found"}

      invitation ->
        {:ok, invitation}
    end
  end

  def get_all(%{page_size: page_size, page_number: page_number, org_id: org_id}) do
    paginated_invitation_data =
      Invitation
      |> where([invitation], invitation.org_id == ^org_id)
      |> order_by(desc: :inserted_at)
      |> Repo.paginate(page: page_number, page_size: page_size)

    invitation_data_with_preloads =
      paginated_invitation_data.entries |> Repo.preload([:role, inviter: :user_credentials])

    ModelHelper.paginated_response(invitation_data_with_preloads, paginated_invitation_data)
  end

  def get_by_email(email) do
    Repo.get_by(Invitation, email: email)
  end

  def get_by_email_n_org(email, org_id) do
    Repo.get_by(Invitation, email: email, org_id: org_id)
  end

  def get_by_token(token) do
    Repo.get_by(Invitation, token: token, token_valid: true)
  end

  def delete(%Invitation{} = invitation) do
    Repo.delete(invitation)
  end

  defp check_for_existing_user(email) do
    User.verify_email(email)
  end
end
