defmodule ChatRoomsWeb.ChatroomLive do
  alias ChatRoomsWeb.RoomsForm
  alias ChatRoomsWeb.MessagesComponent
  use ChatRoomsWeb, :live_view

  alias ChatRooms.Chatrooms
  alias ChatRoomsWeb.RoomsComponent
  alias ChatRoomsWeb.MessagesForm

  def mount(%{"room_id" => room_id}, _session, %{assigns: %{live_action: :show}} = socket) do
    {
      :ok,
      socket
      # Automatically makes a
      |> assign_room!(room_id)
      |> stream_rooms()
      |> maybe_subscribe_rooms()
      |> stream_messages(room_id)
      |> maybe_subscribe_messages(room_id)
    }
  end

  def assign_room!(socket, room_id), do: socket |> assign(room: Chatrooms.get_room!(room_id))

  def mount(_p, _s, %{assigns: %{live_action: :index}} = socket) do
    {:ok,
     socket
     |> stream(:rooms, Chatrooms.list_rooms())
     |> maybe_subscribe_rooms()}
  end

  defp stream_rooms(socket), do: socket |> stream(:rooms, Chatrooms.list_rooms())

  defp stream_messages(socket, room_id),
    do: socket |> stream(:messages, Chatrooms.list_all_messages_from_room(room_id))

  defp maybe_subscribe_rooms(socket) do
    if socket |> connected?(), do: Chatrooms.subscribe_rooms()

    socket
  end

  defp maybe_subscribe_messages(socket, room_id) do
    if socket |> connected?(), do: Chatrooms.subscribe_messages(room_id)

    socket
  end

  def render(%{live_action: :index} = assigns) do
    ~H"""
    <h1>Select a room</h1>
    <RoomsComponent.render id="rooms-list" rooms_stream={@streams.rooms} />
    <.live_component module={RoomsForm} id="rooms-form" />
    """
  end

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <RoomsComponent.render id="rooms-list" rooms_stream={@streams.rooms} />
    <.live_component module={RoomsForm} id="rooms-form" />
    <MessagesComponent.render id="messages-display" messages_stream={@streams.messages} />
    <.live_component module={MessagesForm} id="messages-form" room_id={@room.id} />

    <ul></ul>
    """
  end

  ######################################
  #
  ######################################

  def handle_event("delete-room", %{"id" => id}, socket) do
    {:ok, _} =
      Chatrooms.get_room!(id)
      |> Chatrooms.delete_room()

    IO.puts("Hey")
    {:noreply, socket}
  end

  defp redirect_room_upon_deleting(%{assigns: %{room: room}} = socket) do
    socket
    |> push_navigate(to: ~p"/rooms")
    |> put_flash(:error, "#{room.name} has been deleted.")
  end

  defp redirect_room_upon_deleting(socket), do: socket

  ######################################
  # CODE PUBSUB
  ######################################

  # Room handling
  def handle_info({:room_created, room}, socket) do
    {:noreply, socket |> stream_insert(:rooms, room, at: 0)}
  end

  def handle_info({:room_deleted, room}, socket) do
    {:noreply, socket |> redirect_room_upon_deleting() |> stream_delete(:rooms, room)}
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
