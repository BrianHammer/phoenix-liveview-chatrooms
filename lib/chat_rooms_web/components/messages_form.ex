defmodule ChatRoomsWeb.MessagesForm do
  alias ChatRooms.Chatrooms.Message
  alias ChatRooms.Chatrooms
  use Phoenix.LiveComponent

  import ChatRoomsWeb.CoreComponents

  def mount(socket) do
    {:ok,
     socket
     |> assign_empty_message_form()}
  end

  defp assign_empty_message_form(socket),
    do:
      socket
      |> assign(form: %Message{} |> Chatrooms.change_message(%{}) |> to_form())

  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        id="messages-form"
        phx-submit="message-submit"
        phx-hook="Form"
        phx-target={@myself}
      >
        <.input field={@form[:username]} type="text" id="name" placeholder="Your name" autofocus />

        <.input field={@form[:text]} type="text" id="msg" placeholder="Your message" />

        <input
          field={@room.id}
          id="hidden-room-id"
          type="hidden"
          name={@form[:room_id].name}
          value={@room.id}
        />

        <button type="submit" class="...">Send</button>
      </.form>
    </div>
    """
  end

  # def handle_event("message-change", params, socket) do
  #  IO.inspect(params)

  #  new_form =
  #    %Message{}
  #    |> Chatrooms.change_message(params)
  #    |> to_form()

  #  {:noreply, socket |> assign(form: new_form)}
  # end

  def handle_event("message-submit", %{"message" => inputs}, socket) do
    IO.inspect(inputs)

    case Chatrooms.create_message(inputs) do
      {:error, changeset} ->
        IO.puts("Message error")
        IO.inspect(changeset)
        {:noreply, socket |> assign(form: changeset |> to_form())}

      {:ok, _message} ->
        IO.puts("Message submitted")
        {:noreply, socket |> assign_empty_message_form()}
    end

    {:noreply, socket}
  end

  # def handle_event("message-submit", %{"message" => params}, socket) do
  # case Message.create_message(params) do
  #  {:error, changeset} ->
  #    {:noreply, assign(socket, form: changeset |> #to_form())}

  #  :ok ->
  #    form =
  #      %Message{} |> Message.changeset(%{message: "", name: ""}) |> to_form()

  #    {:noreply, assign(socket, form: form)}
  # end
  # end

  # def handle_event("message-changed", %{"message" => params}, socket) do
  # new_form =
  #  %Message{}
  #  |> Message.changeset(%{message: params[:message], name: params[:name]})
  #  |> to_form()

  # {:noreply, assign(socket, form: new_form)}
  # end
end
