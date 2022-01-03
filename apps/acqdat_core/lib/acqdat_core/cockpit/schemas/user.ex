defmodule AcqdatCore.Cockpit.Schemas.User do
  @moduledoc """
  Schemas for cockpit users
  """

  use AcqdatCore.Schema
  alias Comeonin.Argon2

  @password_min_length 8
  @required_keys ~w(first_name email password uuid slug)a
  @cast_keys ~w(first_name email password password_hash last_name uuid slug phone_number avatar status)a
  @initiate_keys ~w(first_name email password)a

  schema("cockpit_users") do
    field(:first_name, :string, null: false)
    field(:last_name, :string)
    field(:email, :string, null: false)
    field(:uuid, :string, null: false)
    field(:slug, :string, null: false)
    field(:phone_number, :string)
    field(:avatar, :string)
    field(:status, :string, default: "init")
    field(:password_hash, :string)
    field(:password, :string, virtual: true)

    timestamps(type: :utc_datetime)
  end

  def initial_changeset(%__MODULE__{} = cockpit_user, params) do
    cockpit_user
    |> cast(params, @initiate_keys)
    |> add_slug()
    |> add_uuid()
    |> validate_required(@initiate_keys)
    |> validate_format(:email, ~r/@/)
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    |> put_pass_hash()
  end

  def registration_changeset(%__MODULE__{} = cockpit_user, params) do
    cockpit_user
    |> cast(params, @cast_keys)
    |> add_slug()
    |> add_uuid()
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

  def update_changeset(%__MODULE__{} = cockpit_user, params) do
    cockpit_user
    |> cast(params, @cast_keys)
    |> add_slug()
    |> add_uuid()
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

  def reset_password_changeset(%__MODULE__{} = cockpit_user, params) do
    cockpit_user
    |> cast(params, [:password])
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

  defp add_uuid(%Ecto.Changeset{valid?: true} = changeset),
    do: put_change(changeset, :uuid, UUID.uuid1(:hex))

  defp add_slug(%Ecto.Changeset{valid?: true} = changeset),
    do: put_change(changeset, :slug, Slugger.slugify(random_string(12)))

  defp random_string(length),
    do: :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)

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
