defmodule AcqdatCore.Repo.Migrations.CreateStreamPipelines do
  use Ecto.Migration

  def change do
    create table("acqdat_streams_pipelines", primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string, null: false)
      add(:description, :string)
      
      add(:project_id, references("acqdat_projects", on_delete: :delete_all), null: false)
      
      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_streams_pipelines", [:project_id])
  end
end
