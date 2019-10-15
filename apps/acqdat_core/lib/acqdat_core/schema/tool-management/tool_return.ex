defmodule AcqdatCore.Schema.ToolManagement.ToolReturn do
  @moduledoc """
  Models metadata table to store tool issue information.
  """

  use AcqdatCore.Schema
  alias AcqdatCore.Schema.ToolManagement.{Employee, Tool, ToolBox, ToolIssue}

  @typedoc """
    `return_time`: time at which tool was issued.
    `employee_id`: employee id of person who issued.
    `tool_id`: id of the tool issued.
    `tool_box_id`: id of box from which tool was issued.
    `tool_issue_id`: id of issue against which return was made.
  """
  @type t :: %__MODULE__{}

  schema("acqdat_tm_tool_return") do
    field(:return_time, :utc_datetime)

    # associations
    belongs_to(:employee, Employee)
    belongs_to(:tool, Tool)
    belongs_to(:tool_box, ToolBox)
    belongs_to(:tool_issue, ToolIssue)

    timestamps(type: :utc_datetime)
  end

  @permitted ~w(return_time employee_id tool_id tool_box_id tool_issue_id)a

  def changeset(%__MODULE__{} = tool_issue, params) do
    tool_issue
    |> cast(params, @permitted)
    |> validate_required(@permitted)
    |> assoc_constraint(:employee)
    |> assoc_constraint(:tool)
    |> assoc_constraint(:tool_box)
    |> assoc_constraint(:tool_issue)
    |> unique_constraint(:tool_issue,
      name: :unique_issue_for_return,
      message: "unique issue and return combination"
    )
  end
end
