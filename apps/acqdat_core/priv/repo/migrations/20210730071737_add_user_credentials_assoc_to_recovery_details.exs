defmodule AcqdatCore.Repo.Migrations.AddUserCredentialsAssocToRecoveryDetails do
  use Ecto.Migration

  def change do
    alter table("acqdat_recovery_details") do
      add(:user_credentials_id, references("acqdat_user_credentials"), on_delete: :delete_all)
      remove(:user_id)
    end
  end
end
