defmodule AcqdatCore.Repo.Migrations.AlterSiteTable do
  use Ecto.Migration

  def change do
    alter table("acqdat_sites") do
      add(:location_details, :map)
      add(:image_url, :string)
    end
  end
end
