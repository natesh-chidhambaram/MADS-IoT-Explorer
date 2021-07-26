defmodule AcqdatApiWeb.UserSocket do
  use Phoenix.Socket
  @secret_key_base Application.get_env(:acqdat_api, AcqdatApiWeb.Endpoint)[:secret_key_base]

  ## Channels
  channel("tasks:*", AcqdatApiWeb.DataCruncher.TasksChannel)
  channel("project_fact_table:*", AcqdatApiWeb.DataInsights.TasksChannel)
  channel("visualizations:*", AcqdatApiWeb.DataInsights.VisualizationsChannel)
  channel("panels:*", AcqdatApiWeb.DashboardManagement.PanelsChannel)

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  # socket = new Socket("/socket", {params: {token: window.userToken}})
  def connect(%{"token" => token}, socket, _) do
    case Phoenix.Token.verify(
           socket,
           @secret_key_base,
           token,
           max_age: 86_400
         ) do
      {:ok, %{user_id: user_id, org_id: org_id}} ->
        socket =
          socket
          |> assign(:user_token, token)
          |> assign(:org_id, org_id)
          |> assign(:user_id, user_id)

        {:ok, socket}

      {:error, _} ->
        :error
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     AcqdatApiWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_), do: nil
end
