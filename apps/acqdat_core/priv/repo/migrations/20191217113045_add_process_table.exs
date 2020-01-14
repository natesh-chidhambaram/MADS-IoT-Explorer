defmodule AcqdatCore.Repo.Migrations.AddProcessTable do
  use Ecto.Migration

  def change do
    create table("acqdat_processes") do
      add(:name, :string, null: false)
      add(:site_id, references("acqdat_sites", on_delete: :delete_all), null: false)
      add(:image_url, :string)
      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_processes", [:name, :site_id], name: :unique_process_per_site)
  end
end
