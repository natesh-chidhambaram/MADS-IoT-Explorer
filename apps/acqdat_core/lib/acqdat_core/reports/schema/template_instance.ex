defmodule AcqdatCore.Reports.Schema.TemplateInstance do
  use AcqdatCore.Schema
  alias AcqdatCore.Schema.RoleManagement.User
  alias AcqdatCore.Reports.Schema.TemplateInstance.Page

  schema("acqdat_reports_template_instances") do
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

  def changeset(%__MODULE__{} = template_instance, attrs) do
    template_instance
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> unique_constraint(:name, name: :acqdat_reports_template_instances_name_index)
    |> add_uuid()
    |> cast_embed(:pages, with: &Page.changeset/2)
  end

  def update_changeset(%__MODULE__{} = template_instance, attrs) do
    template_instance
    |> cast(attrs, @permitted)
    |> validate_required(@required)
    |> cast_embed(:pages, with: &Page.changeset/2)
  end
end

defmodule AcqdatCore.Reports.Schema.TemplateInstance.Page do
  @moduledoc """
  Embedded Schema for pages of TemplateInstance.
  """
  use AcqdatCore.Schema
  alias AcqdatCore.Reports.Schema.TemplateInstance.PageElement

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

defmodule AcqdatCore.Reports.Schema.TemplateInstance.PageElement do
  use AcqdatCore.Schema

  @moduledoc """
    Assuming we need below fields for reason.
    layout - elem position
    styles - color
    options - flag, widget_instance_id, content - hello word
    type - h1
    subtype - (maybe) for widget subtype
    uid - when something needs to refer this element.
  """

  embedded_schema do
    field(:layout, :map)
    field(:styles, :map)
    field(:options, :map)
    field(:type, :string)
    field(:sub_type, :string)
    field(:uid, :string)
  end

  @permitted ~w(layout styles options type sub_type uid)a
  @required ~w(layout styles options type uid)a

  def changeset(%__MODULE__{} = page_element, attrs) do
    page_element
    |> cast(attrs, @permitted)
    |> validate_required(@required)
  end
end
