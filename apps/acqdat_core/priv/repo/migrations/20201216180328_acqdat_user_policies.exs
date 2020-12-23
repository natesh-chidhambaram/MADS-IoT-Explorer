defmodule AcqdatCore.Repo.Migrations.AcqdatUserPolicies do
  use Ecto.Migration

  def change do
    # create table("acqdat_user_policies") do
    #   add(:user_id, references(:users, on_delete: :delete_all), null: false)
    #   add(:policy_id, references("acqdat_policies", on_delete: :restrict), null: false)
    # end

    # create unique_index("acqdat_user_policies", [:policy_id, :user_id])
  end
end
