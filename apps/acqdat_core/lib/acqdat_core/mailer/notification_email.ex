defmodule AcqdatCore.Mailer.NotificationEmail do
  use Bamboo.Phoenix, view: AcqdatCore.EmailView
  import Bamboo.Email

  @to_address "arjun289singh@gmail.com"
  @from_address "arjun289singh@gmail.com"
  @subject "Device Notification ACQDAT"

  def email(device, message_list) do
    new_email()
    |> from(@from_address)
    |> to(@to_address)
    |> subject(@subject)
    |> put_html_layout({AcqdatCore.EmailView, "email.html"})
    |> render("notification_email.html", message_list: message_list, device: device)
  end
end
