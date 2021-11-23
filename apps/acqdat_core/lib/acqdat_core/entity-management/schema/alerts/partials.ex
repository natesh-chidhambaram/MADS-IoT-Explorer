defmodule AcqdatCore.EntityManagement.Schema.Partials do
  use AcqdatCore.Schema

  @primary_key false
  embedded_schema do
    field(:name, :string, null: false)
    field(:policy_name, EntityPolicyDefinitionModuleEnum, null: false)
    field(:logic, :string, default: nil)

    embeds_one :entity_parameters, EntityParameters, on_replace: :delete do
      field(:name, :string, null: false)
      field(:uuid, :string, null: false)
      field(:data_type, :string, null: false)
      field(:unit, :string)
    end

    field(:rule_parameters, :map, null: false)
  end

  @params ~w(name policy_name logic rule_parameters)a
  @embedded_required_params ~w(name uuid data_type)a
  @embedded_optional_params ~w(unit)a
  @permitted_embedded @embedded_optional_params ++ @embedded_required_params

  def changeset(%__MODULE__{} = partials, params) do
    partials
    |> cast(params, @params)
    |> cast_embed(:entity_parameters, with: &parameters_changeset/2)
    |> validate_required(@params)
    |> unique_constraint(:name, name: :partial_name_not_unique)
  end

  defp parameters_changeset(schema, params) do
    schema
    |> cast(params, @permitted_embedded)
    |> validate_required(@embedded_required_params)
  end
end
