defmodule AcqdatApiWeb.Validators.Metrics.ReportMetric do
  import Ecto.Changeset

  alias AcqdatApi.Utils.Helper

  use Params.Schema, %{
    org_id: :string,
    app: :string,
    entity: :string,
    start_date: :string,
    end_date: :string,
    group_action: :string,
    type: :string
  }

  @required_keys ~w(org_id type start_date end_date group_action)a
  @cast_keys ~w(org_id type app entity group_action start_date end_date)a
  @valid_group_actions ~w(daily weekly monthly quaterly yearly)
  @valid_types ~w(column cards list highlights)

  def validate_params(params) do
    %__MODULE__{}
    |> cast(params, @cast_keys)
    |> validate_required(@required_keys)
    |> update_change(:type, &String.downcase/1)
    |> validate_inclusion(:type, @valid_types)
    |> update_change(:group_action, &String.downcase/1)
    |> validate_inclusion(:group_action, @valid_group_actions)
    |> update_change(:start_date, &Helper.string_to_date/1)
    |> update_change(:end_date, &Helper.string_to_date/1)
    |> is_group_action_in_date_range()
  end

  defp is_group_action_in_date_range(%Ecto.Changeset{valid?: true} = changeset) do
    date_diff =
      changeset
      |> fetch_change!(:end_date)
      |> get_date_diff(fetch_change!(changeset, :start_date))

    if date_diff < Helper.convert_group_action_to_days(fetch_change!(changeset, :group_action)) do
      {:validation_error,
       add_error(
         changeset,
         :group_action,
         "period should be smaller than (end_date - start_date)"
       )}
    else
      {:ok, Params.to_map(changeset)}
    end
  end

  defp is_group_action_in_date_range(changeset), do: {:validation_error, changeset}

  defp get_date_diff(end_date, start_date), do: Date.diff(end_date, start_date)
end
