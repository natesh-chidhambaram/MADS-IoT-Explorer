defmodule Notifications.Vendors.Twilio do
  @moduledoc """
    Twilio service will be used to send the notification of alert in form of sms or in whatsapp
  """
  alias Notifications.Behaviour.Whatsapp
  alias Notifications.Behaviour.SMS
  @behaviour Whatsapp
  @behaviour SMS

  @impl
  def send_message(message, to, from) do
    ExTwilio.Message.create(to: to, from: from, body: message)
  end

  @impl
  def send_sms(message, to, from) do
    ExTwilio.Message.create(to: to, from: from, body: message)
  end
end
