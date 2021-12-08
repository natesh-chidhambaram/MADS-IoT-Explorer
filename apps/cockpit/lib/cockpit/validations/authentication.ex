defmodule Cockpit.Validations.Authentication do
  @moduledoc """
  Functions to validate params for authenticatoin related APIs.
  """
  use Params

  defparams(
    validate_registration_credentials(%{
      first_name!: :string,
      last_name: :string,
      email!: :string,
      password!: :string,
      phone_number: :string,
      avatar: :string
    })
  )

  defparams(
    validate_signin_credentials(%{
      email!: :string,
      password!: :string
    })
  )
end
