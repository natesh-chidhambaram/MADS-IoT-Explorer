defmodule AcqdatCore.Reports.Schema.Template do
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.RoleManagement.User

  schema("acqdat_reports_templates") do
    field(:uuid, :string)
    field(:name, :string)
    field(:type, :string)

    belongs_to(:creator, User,
    references: :id,
    foreign_key: :created_by_user_id
  )

    embeds_many :pages, Pages, on_replace: :delete do
      field(:page_number, :string, null: false)

      embeds_many :elements, PageElements, on_replace: :delete do
        field(:visual_settings, :map)
        field(:data_settings, :map)
      end
    end
  end

  @required ~w(pages name uuid)a
  @optional ~w(type)a
  @permitted @optional ++ @required

  def changeset(%__MODULE__{} = template, params) do
    template
    |> cast(params, @permitted)
    |> validate_required(@required)
    # |> common_changeset(params)

  end

  def update_changeset(%__MODULE__{} = template, params) do
    #
  end

  # def common_changeset(changeset, _params) do
  #   changeset
  #   |> assoc_constraint(:role)
  # end

end
