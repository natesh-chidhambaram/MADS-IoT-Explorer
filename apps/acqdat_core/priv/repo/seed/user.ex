defmodule AcqdatCore.Seed.User do

  alias AcqdatCore.Schema.User
  alias AcqdatCore.Repo

  def seed_user!() do
    params = %{
      first_name: "Chandu",
      last_name: "Developer",
      email: "chandu@stack-avenue.com",
      password: "datakrew",
      password_confirmation: "datakrew",
    }
    user = User.changeset(%User{}, params)
    Repo.insert!(user, on_conflict: :nothing)
  end
end
