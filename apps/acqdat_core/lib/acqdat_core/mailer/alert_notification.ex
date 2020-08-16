defmodule AcqdatCore.Mailer.AlertNotification do
  use Bamboo.Phoenix, view: AcqdatCore.EmailView
  import Bamboo.Email

  @subject "Alert"
  @from_address "admin@datakrew.com"

  def email(recepient_mails, alert, user) do
    new_email()
    |> from(@from_address)
    |> to(recepient_mails)
    |> subject(@subject)
    |> put_html_layout({AcqdatCore.EmailView, "email.html"})
    |> render("alert_notification.html",
      alert: alert,
      user: user
    )
  end
end
