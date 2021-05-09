defmodule AcqdatCore.Repo.Migrations.AddTabsTable do
  use Ecto.Migration

  def change do
    create table("acqdat_tab") do
      add(:name, :string, null: false)
      add(:description, :string)
      add(:uuid, :string, null: false)
      add(:slug, :string, null: false)
      add(:image_url, :string)
      add(:image_settings, :map)
      add(:org_id, references("acqdat_organisation", on_delete: :delete_all), null: false)
      add(:digital_twin_id, references("acqdat_digital_twins", on_delete: :delete_all), null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_tab", [:slug])
    create unique_index("acqdat_tab", [:uuid])
    create unique_index("acqdat_tab", [:digital_twin_id, :name], name: :unique_tab_name_per_digital_twin)
  end
end
