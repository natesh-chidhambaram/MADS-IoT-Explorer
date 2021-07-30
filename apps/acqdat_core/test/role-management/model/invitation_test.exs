defmodule AcqdatCore.Model.RoleManagement.InvitationTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.RoleManagement.Invitation, as: InvitationModel
  alias AcqdatCore.Schema.RoleManagement.Invitation

  describe "create_invitation/1" do
    setup do
      org = insert(:organisation)
      role = insert(:role)
      [org: org, role: role]
    end

    test "creates a invitation with supplied params", context do
      %{org: org, role: role} = context
      inviter = insert(:user)

      params = %{
        "email" => "test90@gmail.com",
        "inviter_id" => inviter.id,
        "org_id" => org.id,
        "role_id" => role.id
      }

      assert {:ok, _usersetting} = InvitationModel.create_invitation(params)
    end

    test "fails if inviter_id is not present", context do
      %{org: org, role: role} = context
      params = %{"email" => "test90@gmail.com", "org_id" => org.id, "role_id" => role.id}

      assert {:error, changeset} = InvitationModel.create_invitation(params)
      assert %{inviter_id: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "get_by_email/1" do
    test "returns a particular invitation record" do
      invitation = insert(:invitation)

      result = InvitationModel.get_by_email(invitation.email)
      assert not is_nil(result)
      assert result.email == invitation.email
    end

    test "returns error not found, if setting is not present" do
      result = InvitationModel.get_by_email("dummy_email@email.email")
      assert result == nil
    end
  end

  describe "delete/1" do
    test "deletes a particular invitation record" do
      invitation = insert(:invitation)
      result = InvitationModel.get_by_email(invitation.email)
      assert not is_nil(result)
      {:ok, result} = InvitationModel.delete(invitation)
      assert result
      result = InvitationModel.get_by_email(invitation.email)
      assert is_nil(result)
    end
  end

  describe "get_all" do
    test "returns invitations data" do
      invitation = insert(:invitation)

      params = %{page_size: 10, page_number: 1, org_id: invitation.org_id}
      result = InvitationModel.get_all(params)

      assert not is_nil(result)
      assert result.total_entries == 1
    end

    test "returns error not found, if teams are not present" do
      params = %{page_size: 10, page_number: 1, org_id: 1}
      result = InvitationModel.get_all(params)

      assert result.entries == []
      assert result.total_entries == 0
    end
  end

  describe "list_invitations" do
    test "lists current invitations" do
      invite1 = insert(:invitation)
      invite2 = insert(:invitation)

      [record1, record2] = InvitationModel.list_invitations()

      assert invite1.id == record1.id
      assert invite2.id == record2.id
    end
  end

  describe "return_count/1" do
    test "returns count for valid org_id" do
      invite = insert(:invitation)
      count = InvitationModel.return_count(%{"type" => "UserInvite", "org_id" => invite.org_id})
      assert count == 1
    end

    test "does not crash for invalid org_id" do
      invite = insert(:invitation)
      count = InvitationModel.return_count(%{"type" => "UserInvite", "org_id" => -1})
      assert count == 0
    end

    test "returns count without org_id" do
      invite1 = insert(:invitation)
      invite2 = insert(:invitation)
      count = InvitationModel.return_count(%{"type" => "UserInvite"})
      assert count == 2
    end
  end

  describe "update_invitation/1" do
    setup do
      org = insert(:organisation)
      role = insert(:role)
      [org: org, role: role]
    end

    test "updates an invitation with supplied params", context do
      %{org: org, role: role} = context
      inviter1 = insert(:user)

      params = %{
        "email" => "test90@gmail.com",
        "inviter_id" => inviter1.id,
        "org_id" => org.id,
        "role_id" => role.id
      }

      assert {:ok, invite} = InvitationModel.create_invitation(params)

      inviter2 = insert(:user)

      params = %{
        "email" => "test91@gmail.com",
        "inviter_id" => inviter2.id
      }

      assert {:ok, new_invite} = InvitationModel.update_invitation(invite, params)
      assert Map.fetch(new_invite, :email) == {:ok, "test91@gmail.com"}
      assert Map.fetch(new_invite, :inviter_id) == {:ok, inviter2.id}
    end

    test "fails if invite is not present", context do
      %{org: org, role: role} = context
      inviter1 = insert(:user)

      params = %{
        "email" => "test91@gmail.com",
        "inviter_id" => inviter1.id,
        "org_id" => org.id,
        "role_id" => role.id
      }

      invite = %Invitation{
        email: "test90@gmail.com",
        inviter_id: inviter1.id,
        org_id: org.id,
        role_id: role.id
      }

      assert {:error, _} = InvitationModel.update_invitation(invite, params)
    end
  end

  describe "update_invitation_token/1" do
    setup do
      org = insert(:organisation)
      role = insert(:role)
      [org: org, role: role]
    end

    test "updates an invitation with supplied params", context do
      %{org: org, role: role} = context
      inviter1 = insert(:user)

      params = %{
        "email" => "test90@gmail.com",
        "inviter_id" => inviter1.id,
        "org_id" => org.id,
        "role_id" => role.id
      }

      assert {:ok, invite} = InvitationModel.create_invitation(params)
      token1 = invite.token

      InvitationModel.update_invitation_token(invite, %{
        "email" => "test90@gmail.com",
        "org_id" => org.id
      })

      assert [new_invite] = InvitationModel.list_invitations()
      assert token1 != new_invite.token
    end

    test "error if invite is not present", context do
      %{org: org, role: role} = context
      inviter1 = insert(:user)

      params = %{
        "email" => "test91@gmail.com",
        "inviter_id" => inviter1.id,
        "org_id" => org.id,
        "role_id" => role.id
      }

      invite = %Invitation{
        email: "test90@gmail.com",
        inviter_id: inviter1.id,
        org_id: org.id,
        role_id: role.id
      }

      assert {:error, _} = InvitationModel.update_invitation_token(invite, params)
    end
  end

  describe "get/1" do
    test "returns a particular invitation record" do
      invitation = insert(:invitation)

      {:ok, result} = InvitationModel.get(invitation.id)
      assert not is_nil(result)
      assert result.id == invitation.id
    end

    test "returns error not found, if setting is not present" do
      assert {:error, "not found"} = InvitationModel.get(-1)
    end
  end

  describe "get_by_email_n_org/2" do
    test "returns a particular invitation record" do
      invitation = insert(:invitation)

      result = InvitationModel.get_by_email_n_org(invitation.email, invitation.org_id)
      assert not is_nil(result)
      assert result.email == invitation.email
      assert result.org_id == invitation.org_id
    end

    test "returns error not found, if setting is not present" do
      result = InvitationModel.get_by_email_n_org("dummy_email@email.email", -1)
      assert result == nil
    end
  end

  describe "get_by_token/1" do
    test "returns a particular invitation record" do
      invitation = insert(:invitation)

      result = InvitationModel.get_by_token(invitation.token)
      assert not is_nil(result)
      assert result.token == invitation.token
    end

    test "returns error not found, if setting is not present" do
      result = InvitationModel.get_by_token("BadToken")
      assert result == nil
    end
  end
end
