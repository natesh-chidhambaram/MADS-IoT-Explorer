defmodule AcqdatCore.Repo.Migrations.AddToolTable do
  use Ecto.Migration

  def change do
    create table("acqdat_tm_tools") do
      add(:uuid, :string, null: false)
      add(:name, :string, null: false)
      add(:status, :string, null: false)
      add(:description, :string)

      add(:tool_box_id, references("acqdat_tm_tool_boxes", on_delete: :delete_all), null: false)
      add(:tool_type_id, references("acqdat_tm_tool_types", on_delete: :delete_all), null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_tm_tools", [:uuid])
    create unique_index("acqdat_tm_tools", [:name, :tool_box_id])
  end
end
