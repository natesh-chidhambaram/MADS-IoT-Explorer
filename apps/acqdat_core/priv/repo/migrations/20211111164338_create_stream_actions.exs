defmodule AcqdatCore.Repo.Migrations.CreateStreamActions do
  use Ecto.Migration

  def change do
    create table("acqdat_streams_actions", primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:type, :string, null: false)
      add(:name, :string)
      add(:config, :map)
      
      add(:pipeline_id, references("acqdat_streams_pipelines", on_delete: :delete_all, type: :binary_id), null: false)
      
      timestamps(type: :timestamptz)
    end

    create index("acqdat_streams_actions", [:pipeline_id])
  end
end
