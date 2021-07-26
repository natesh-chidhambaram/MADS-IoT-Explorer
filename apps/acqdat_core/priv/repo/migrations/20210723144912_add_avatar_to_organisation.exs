defmodule AcqdatCore.Repo.Migrations.AddAvatarToOrganisation do
  use Ecto.Migration

  def change do
    alter table("acqdat_organisation") do
      add(:avatar, :string)
    end
  end
end
