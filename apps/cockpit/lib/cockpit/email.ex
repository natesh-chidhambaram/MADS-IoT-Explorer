defmodule Cockpit.Email do
  @moduledoc false
  use Bamboo.Phoenix, view: CockpitWeb.EmailView
  alias CockpitWeb.LayoutView

  @from_email Application.get_env(:cockpit, :from_email)

  def send_password_email(user, url) do
    new_email()
    |> subject("Reset your Password")
    |> from(@from_email)
    |> to(user.email)
    |> assign(:user, user)
    |> assign(:url, url)
    |> put_html_layout({LayoutView, "email.html"})
    |> render("new_password.html")
  end
end
