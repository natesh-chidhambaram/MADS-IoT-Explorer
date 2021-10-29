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

    embeds_many(:pages, Page, on_replace: :delete)
  end

  @required ~w(name)a
  @optional ~w(type)a
  @permitted @optional ++ @required

  def changeset(%__MODULE__{} = template, attrs) do
    template
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> unique_constraint(:name, name: :acqdat_reports_templates_name_index)
    |> add_uuid()
    |> cast_embed(:pages, with: &Page.changeset/2)
  end


  def update_changeset(%__MODULE__{} = template, attrs) do
    template
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> cast_embed(:pages, with: &Page.changeset/2)
  end

end

defmodule AcqdatCore.Reports.Schema.Template.Page do
  @moduledoc """
  Embedded Schema for pages of Template.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Reports.Schema.Template.PageElement

  embedded_schema do
    field(:page_number, :integer)
    embeds_many(:elements, PageElement, on_replace: :delete)
  end

  @permitted ~w(page_number)a
  def changeset(%__MODULE__{} = page, attrs) do
    page
    |> cast(attrs, @permitted)
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

  def changeset(%__MODULE__{} = page_element, attrs) do
    page_element
    |> cast(attrs, @permitted)
    |> validate_required(@required)
  end
end
