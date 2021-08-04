defmodule AcqdatCore.Repo.Migrations.AddSubtreeLeafNodesColumnsToFactTables do
  use Ecto.Migration

  def change do
  	alter table("acqdat_fact_tables") do
      add(:leaf_nodes, {:array, :map})
      add(:subtree, :map)
    end
  end
end
