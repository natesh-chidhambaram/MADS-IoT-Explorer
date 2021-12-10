defmodule CockpitWeb.AuthView do
  use CockpitWeb, :view

  def render("register.json", assigns) do
    %{status: assigns.status}
  end

  def render("signin.json", manifest) do
    %{
      email: manifest.email,
      credentials_id: manifest.credentials_id,
      access_token: manifest.access_token,
      refresh_token: manifest.refresh_token
    }
  end

  def render("forgot_password.json", assigns) do
    %{status: assigns.status}
  end

  def render("reset_password.json", assigns) do
    %{status: assigns.status}
  end
end
