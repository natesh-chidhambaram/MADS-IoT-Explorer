defmodule AcqdatCore.Repo.Migrations.AddGatewayParameterVersion do
  use Ecto.Migration

  def change do
    alter table("acqdat_gateway") do
      add :version, :decimal, default: 1.0, precision: 2, scale: 1
    end
  end
end
