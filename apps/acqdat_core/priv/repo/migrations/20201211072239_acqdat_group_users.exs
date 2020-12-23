defmodule AcqdatCore.Repo.Migrations.AcqdatGroupUsers do
  use Ecto.Migration

  def change do
    # create table("acqdat_group_users") do
    #   add(:group_id, references("acqdat_groups", on_delete: :delete_all), null: false)
    #   add(:user_id, references(:users, on_delete: :restrict), null: false)
    # end

    # create unique_index("acqdat_group_users", [:user_id, :group_id])
  end
end
