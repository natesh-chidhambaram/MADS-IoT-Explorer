defmodule AcqdatCore.Repo.Migrations.AlterInvitation do
  use Ecto.Migration

  def change do
    alter table("acqdat_invitations") do
      add(:group_ids, {:array, :integer})
      add(:policies, {:array, :map})
    end
  end
end
