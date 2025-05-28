defmodule ChatRoomsWeb.ChatroomLive do
  alias ChatRoomsWeb.RoomsForm
  alias ChatRoomsWeb.MessagesComponent
  use ChatRoomsWeb, :live_view

  alias ChatRooms.Chatrooms
  alias ChatRoomsWeb.RoomsComponent
  alias ChatRoomsWeb.MessagesForm

  def mount(_p, _s, socket) do
    {:ok, socket |> stream_rooms() |> maybe_subscribe_rooms()}
  end

  # def handle_params(%{room_id: room_id}, _s, socket) do
  #  {:noreply, socket |> assign_room!(room_id)}
  # end

  def handle_params(%{"room_id" => room_id}, _uri, socket) do
    if connected?(socket), do: IO.puts("Handling params from socket")

    IO.puts("Handling params called...")

    {:noreply,
     socket
     |> unsubscribe_from_current_messages()
     |> assign_room!(room_id)
     |> stream_messages(room_id)
     |> maybe_subscribe_messages(room_id)}
  end

  def handle_params(p, _, socket) do
    IO.inspect(p)
    {:noreply, socket |> unsubscribe_from_current_messages()}
  end

  def assign_room!(socket, room_id), do: socket |> assign(room: Chatrooms.get_room!(room_id))

  defp stream_rooms(socket), do: socket |> stream(:rooms, Chatrooms.list_rooms(), reset: true)

  defp stream_messages(socket, room_id),
    do: socket |> stream(:messages, Chatrooms.list_all_messages_from_room(room_id))

  defp maybe_subscribe_rooms(socket) do
    if socket |> connected?(), do: Chatrooms.subscribe_rooms()

    socket
  end

  defp unsubscribe_from_current_messages(%{assigns: %{room: room}} = socket) do
    Chatrooms.unsubscribe_messages(room.id)

    socket
  end

  defp unsubscribe_from_current_messages(socket) do
    socket
  end

  defp maybe_subscribe_messages(socket, room_id) do
    if socket |> connected?(), do: Chatrooms.subscribe_messages(room_id)

    socket
  end

  ###################################
  ## RENDERING
  ###################################

  def render(%{live_action: :index} = assigns) do
    ~H"""
    <.live_component module={RoomsComponent} id="room-sidebar" rooms_stream={@streams.rooms} />
    """
  end

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <div class="flex flex-row h-screen antialiased text-gray-800 w-full">
      <.live_component module={RoomsComponent} id="room-sidebar" rooms_stream={@streams.rooms} />
      <.live_component
        module={MessagesComponent}
        id="messages-page"
        messages_stream={@streams.messages}
        room={@room}
      />
    </div>

    <.live_component module={MessagesForm} id="messages-form" room_id={@room.id} />
    <.live_component module={RoomsForm} id="rooms-form" />
    <ul></ul>
    """
  end

  #####################################
  # ROOM STREAM
  #####################################

  ######################################
  # EVENTS
  ######################################

  def handle_event("delete-message", %{"id" => id}, socket) do
    {:ok, _} =
      Chatrooms.get_message!(id)
      |> Chatrooms.delete_message()

    {:noreply, socket}
  end

  defp redirect_room_upon_deleting(%{assigns: %{room: room}} = socket, deleted_room)
       when room.id == deleted_room.id do
    socket
    |> push_patch(to: ~p"/rooms")
    |> put_flash(:error, "#{room.name} has been deleted.")
  end

  defp redirect_room_upon_deleting(socket, _deleted_room), do: socket

  ######################################
  # CODE PUBSUB
  ######################################

  # Room handling
  def handle_info({:room_created, room}, socket) do
    {:noreply, socket |> stream_insert(:rooms, room, at: 0)}
  end

  def handle_info({:room_deleted, deleted_room}, socket) do
    {:noreply,
     socket |> redirect_room_upon_deleting(deleted_room) |> stream_delete(:rooms, deleted_room)}
  end

  def handle_info({:room_updated, room}, socket) do
    {:noreply, socket |> stream_insert(:rooms, room)}
  end

  # message handling

  def handle_info({:message_created, message}, socket) do
    {:noreply, socket |> stream_insert(:messages, message, at: 0)}
  end

  def handle_info({:message_deleted, message}, socket) do
    {:noreply, socket |> stream_delete(:messages, message)}
  end

  def handle_info({:message_updated, message}, socket) do
    {:noreply, socket |> stream_insert(:messages, message)}
  end
end
