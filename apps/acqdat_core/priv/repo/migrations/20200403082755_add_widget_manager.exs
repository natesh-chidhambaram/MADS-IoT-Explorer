defmodule AcqdatCore.Repo.Migrations.AddWidgetManager do
  use Ecto.Migration

  def change do
    create table("acqdat_widget_type") do
      add(:name, :string, null: false)
      add(:vendor, WidgetVendorEnum.type(), null: false)
      add(:module, WidgetVendorSchemaEnum.type(), null: false)
      add(:vendor_metadata, :map)

      timestamps(type: :timestamptz)
    end

    create table("acqdat_widgets") do
      add(:label, :string)
      add(:policies, :map)
      add(:default_values, :map)
      add(:uuid, :string, null: false)
      add(:properties, :map)
      add(:visual_settings, :map)
      add(:data_settings, :map)
      add(:category, :map)
      add(:image_url, :string)

      #associations
      add(:widget_type_id, references("acqdat_widget_type", on_delete: :delete_all))

      timestamps(type: :timestamptz)
    end

    create table("acqdat_user_widgets") do
      add(:widget_id, references("acqdat_widgets", on_delete: :delete_all), null: false)
      add(:user_id, references("users", on_delete: :delete_all), null: false)
      timestamps(type: :timestamptz)
    end
    create unique_index("acqdat_user_widgets", [:widget_id, :user_id], name: :unique_widget_per_user)
  end
end
