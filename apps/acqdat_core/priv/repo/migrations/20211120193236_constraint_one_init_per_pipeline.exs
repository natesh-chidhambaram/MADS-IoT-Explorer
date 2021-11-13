defmodule AcqdatCore.Repo.Migrations.ConstraintOneInitPerPipeline do
  use Ecto.Migration

  def change do
    create unique_index("acqdat_streams_actions", [:type, :pipeline_id], name: :atmost_one_init_per_pipeline, where: "type = 'init'")
  end
end
