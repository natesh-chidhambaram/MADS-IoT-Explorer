defmodule AcqdatCore.Repo.Migrations.AddWidgetDataType do
  use Ecto.Migration

  def change do
    alter table("acqdat_widgets") do
      add(:widget_data_type, {:array, :string})
    end

    create index("acqdat_widgets", [:widget_data_type])

  end
end
