defmodule Notifications do
  @moduledoc """
    For sending alert notifications in different modes.
  """
  alias AcqdatCore.Model.RoleManagement.User
  alias AcqdatCore.Mailer.AlertNotification
  alias AcqdatCore.Mailer
  alias Notifications.Vendors

  def send_notifications(alert, vendor) do
    Enum.each(alert.communication_medium, fn medium ->
      case medium do
        "email" -> send_alert(alert)
        "sms" -> send_sms(alert, vendor)
        "whatsapp" -> send_message(alert, vendor)
        "in-app" -> nil
        "e-mail" -> send_alert(alert)
      end
    end)
  end

  def send_alert(alert) do
    Enum.each(alert.recipient_ids, fn recipient ->
      if recipient != 0 do
        user = User.extract_email(recipient)

        user.user_credentials.email
        |> AlertNotification.email(alert, user)
        |> Mailer.deliver_now()
      end
    end)
  end

  defp send_sms(alert, vendor) do
    contacts = create_contact_list(alert)
    message = create_message(alert)

    case List.first(contacts) do
      nil ->
        nil

      _ ->
        Enum.each(contacts, fn contact ->
          Vendors.module(Vendors.services(vendor)).send_sms(message, contact, "+12059646511")
        end)
    end
  end

  defp send_message(alert, vendor) do
    contacts = create_contact_list(alert)
    message = create_message(alert)

    case List.first(contacts) do
      nil ->
        nil

      _ ->
        Enum.each(contacts, fn contact ->
          Vendors.module(Vendors.services(vendor)).send_message(
            message,
            contact,
            "+14155238886"
          )
        end)
    end
  end

  defp create_message(alert) do
    "Hello,
    An alert has been generated in your MADS workspace on #{alert.inserted_at}.

    Below are the details:-

    App: #{alert.alert_app_name}
    Alert Rule: #{alert.name}
    Condition: #{Atom.to_string(alert.policy_name)}
    Severity: #{alert.severity_code}(#{Atom.to_string(alert.severity)}

    Thank you.
    Regards,
    MADSbot
    "
  end

  defp create_contact_list(alert) do
    user_phone_numbers =
      Enum.reduce(alert.recipient_ids, [], fn recipient, acc ->
        if recipient != 0 do
          user = User.extract_email(recipient)
          acc ++ [user.user_credentials.phone_number]
        end
      end)

    user_phone_numbers ++ alert.phone_numbers
  end
end
