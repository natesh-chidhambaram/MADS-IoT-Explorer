defmodule AcqdatCore.Seed.User do

  alias AcqdatCore.Schema.User
  alias AcqdatCore.Repo

  def seed_user!() do
    params = %{
      first_name: "DataKrew",
      last_name: "Admin",
      email: "admin@datakrew.com",
      password: "datakrew",
      password_confirmation: "datakrew",
    }
    user = User.changeset(%User{}, params)
    Repo.insert!(user, on_conflict: :nothing)
  end
end
