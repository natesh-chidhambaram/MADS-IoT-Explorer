defmodule AcqdatCore.Repo.Migrations.AlterSensorGateway do
  use Ecto.Migration

  def up do
    drop constraint("acqdat_sensors", "acqdat_sensors_gateway_id_fkey")
    alter table("acqdat_sensors") do
      modify(:gateway_id, references("acqdat_gateway", on_delete: :nilify_all))
    end
  end

  def down do
    drop constraint("acqdat_sensors", "acqdat_sensors_gateway_id_fkey")
    alter table("acqdat_sensors") do
      modify(:gateway_id, references("acqdat_gateway", on_delete: :delete_all))
    end
  end
end
