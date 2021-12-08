defmodule Cockpit.Schemas.User do
  @moduledoc """
  Model for cockpit users
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Comeonin.Argon2

  @password_min_length 8
  @required_keys ~w(first_name email password)a
  @cast_keys ~w(first_name email password password_hash last_name phone_number avatar)a
  @primary_key {:uuid, :binary_id, autogenerate: true}

  schema("cockpit_users") do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:phone_number, :string)
    field(:avatar, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)

    timestamps(type: :utc_datetime)
  end

  def registration_changeset(%__MODULE__{} = cockpit_user, params) do
    cockpit_user
    |> cast(params, @cast_keys)
    |> validate_required(@required_keys)
    |> validate_format(:email, ~r/@/)
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    |> validate_length(:password, min: @password_min_length)
    |> validate_format(:password, ~r/[0-9]+/, message: "Password must contain a number")
    |> validate_format(:password, ~r/[A-Z]+/,
      message: "Password must contain an upper-case letter"
    )
    |> validate_format(:password, ~r/[a-z]+/, message: "Password must contain a lower-case letter")
    |> validate_format(:password, ~r/[#\!\?&@\$%^&*\(\)]+/,
      message: "Password must contain a symbol"
    )
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> fetch_change(:password)
    |> case do
      {:ok, password} -> change(changeset, Argon2.add_hash(password))
      :error -> changeset
    end
  end

  defp put_pass_hash(changeset), do: changeset
end
