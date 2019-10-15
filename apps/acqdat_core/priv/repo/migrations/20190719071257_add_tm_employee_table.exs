defmodule AcqdatCore.Repo.Migrations.AddTmEmployeeTable do
  use Ecto.Migration

  def change do
    create table("acqdat_tm_employees") do
      add(:name, :string, null: false)
      add(:phone_number, :string, null: false)
      add(:address, :string)
      add(:uuid, :string, null: false)
      add(:role, :string, null: false)

      timestamps(type: :timestamptz)
    end

    create unique_index("acqdat_tm_employees", [:uuid])
    create unique_index("acqdat_tm_employees", [:name, :phone_number])
  end
end
