defmodule AcqdatCore.Reports.Schema.Template do
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.RoleManagement.User
  alias AcqdatCore.Reports.Schema.Template.Page

  schema("acqdat_reports_templates") do
    field(:uuid, :string)
    field(:name, :string)
    field(:type, :string)

    belongs_to(:creator, User,
      references: :id,
      foreign_key: :created_by_user_id
    )

    embeds_many(:pages, Pages, on_replace: :delete)
  end

  @required ~w(pages name uuid)a
  @optional ~w(type)a
  @permitted @optional ++ @required

  def changeset(%__MODULE__{} = template, params) do
    template
    |> cast(params, @permitted)
    |> validate_required(@required)
    |> cast_embed(:pages, with: &Page.changeset/2)

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

defmodule AcqdatCore.Reports.Schema.Template.Page do
  @moduledoc """
  Embedded Schema for pages of Template.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Reports.Schema.Template.PageElement

  embedded_schema do
    field(:page_number, :integer, null: false)

    embeds_many(:elements, PageElements, on_replace: :delete)
  end

  @permitted ~w(page_number elements)a
  def changeset(%__MODULE__{} = page, params) do
    page
    |> cast(params, @permitted)
    |> cast_embed(:elements, with: &PageElement.changeset/2)
  end
end

defmodule AcqdatCore.Reports.Schema.Template.PageElement do
  use AcqdatCore.Schema

  embedded_schema do
    field(:visual_settings, :map)
    field(:data_settings, :map)
  end

  @permitted ~w(visual_settings data_settings)a
  @required ~w(visual_settings)a

  def changeset(%__MODULE__{} = page_element, params) do
    page_element
    |> cast(params, @permitted)
    |> validate_required(@required)
  end
end
