defmodule AcqdatCore.Repo.Migrations.AddTmToolBoxTable do
  use Ecto.Migration

  def change do
    create table("acqdat_tm_tool_boxes") do
      add(:name, :string, null: false)
      add(:description, :string)
      add(:uuid, :string, null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_tm_tool_boxes", [:uuid])
    create unique_index("acqdat_tm_tool_boxes", [:name])
  end
end
