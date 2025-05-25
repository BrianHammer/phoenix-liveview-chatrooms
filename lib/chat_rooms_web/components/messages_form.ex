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
        phx-change="validate"
        phx-target={@myself}
      >
        <.input
          label="Username"
          field={@form[:username]}
          type="text"
          placeholder="Your name"
          phx-debounce="750"
          autofocus
        />

        <.input
          label="Message"
          field={@form[:text]}
          type="text"
          placeholder="Your message"
          phx-debounce="750"
        />

        <input id="hidden-room-id" type="hidden" name="message[room_id]" value={@room_id} />

        <.button type="submit" class="..." phx-disable-with="Sending...">Send</.button>
      </.form>
    </div>
    """
  end

  def handle_event("validate", %{"message" => params}, socket) do
    form =
      %Message{} |> Chatrooms.change_message(params) |> to_form_with_validation()

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("message-submit", %{"message" => inputs}, socket) do
    case Chatrooms.create_message(inputs) do
      {:error, changeset} ->
        {:noreply, socket |> assign(form: changeset |> to_form_with_validation())}

      {:ok, _message} ->
        {:noreply, socket |> assign_empty_message_form()}
    end
  end

  defp to_form_with_validation(changeset),
    do: changeset |> Map.put(:action, :validate) |> to_form()
end
