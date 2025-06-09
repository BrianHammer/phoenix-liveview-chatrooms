defmodule ChatRoomsWeb.ChatroomLive do
  alias Phoenix.PubSub
  alias ChatRoomsWeb.Presence
  use ChatRoomsWeb, :live_view

  alias ChatRoomsWeb.MessagesComponent
  alias ChatRooms.Chatrooms
  alias ChatRoomsWeb.RoomsComponent

  def mount(_p, _s, socket) do
    {:ok,
     socket
     |> stream_rooms()
     |> maybe_subscribe_rooms()}
  end

  # def handle_params(%{room_id: room_id}, _s, socket) do
  #  {:noreply, socket |> assign_room!(room_id)}
  # end

  def handle_params(%{"room_id" => room_id}, _uri, socket) do
    {:noreply,
     socket
     |> untrack_assigned_room()
     |> unsubscribe_from_current_messages()
     |> assign_room!(room_id)
     |> stream_messages(room_id)
     |> maybe_subscribe_messages(room_id)
     |> track_room(room_id)}
  end

  def handle_params(_p, _, socket) do
    {:noreply,
     socket
     |> untrack_assigned_room()
     |> unsubscribe_from_current_messages()
     |> assign(room: nil)}
  end

  defp track_room(socket, room_id) do
    presence_id = socket.id

    if connected?(socket) do
      Presence.track_room(room_id, presence_id)
    end

    socket
    |> assign(presence_id: presence_id)
    |> assign(:presences, Presence.list_room(room_id))
    |> assign(:is_typing, false)
  end

  defp untrack_assigned_room(%{assigns: %{room: room}} = socket) when not is_nil(room) do
    presence_id = socket.id

    if connected?(socket) do
      Presence.untrack_room(room.id, presence_id)
    end

    socket
  end

  defp untrack_assigned_room(socket), do: socket

  def clear_messages(socket) do
    socket
    |> stream(:messages, [], reset: true)
  end

  @spec assign_room!(any(), any()) :: any()
  def assign_room!(socket, room_id),
    do: socket |> assign(room: Chatrooms.get_room!(room_id), reset: true)

  defp stream_rooms(socket) do
    rooms = Chatrooms.list_rooms()

    socket
    |> stream(:rooms, rooms, reset: true)
    |> assign(:last_room_timestamp, rooms |> get_last_room_timestamp())
  end

  defp get_last_room_timestamp([]), do: DateTime.utc_now()

  defp get_last_room_timestamp(rooms_list),
    do: rooms_list |> List.first() |> Map.get(:inserted_at)

  defp stream_messages(socket, room_id) do
    messages = Chatrooms.list_messages_from_room(room_id)

    socket
    |> stream(:messages, messages, reset: true)
    |> assign(:last_message_timestamp, get_last_message_timestamp(messages))
  end

  defp append_messages(socket, room_id, past_timestamp) do
    case Chatrooms.list_messages_from_room(room_id, past_timestamp) do
      [] ->
        socket |> put_flash(:error, "You have reached the top of the page")

      messages ->
        socket
        |> stream(:messages, messages |> Enum.reverse(), at: 0)
        |> assign(:last_message_timestamp, get_last_message_timestamp(messages))
    end
  end

  defp get_last_message_timestamp([]), do: DateTime.utc_now()

  defp get_last_message_timestamp(message_list),
    do: message_list |> List.first() |> Map.get(:inserted_at)

  defp maybe_subscribe_rooms(socket) do
    if socket |> connected?(), do: Chatrooms.subscribe_rooms()

    socket
  end

  defp unsubscribe_from_current_messages(%{assigns: %{room: room}} = socket)
       when not is_nil(room) do
    Chatrooms.unsubscribe_messages(room.id)

    socket
  end

  defp unsubscribe_from_current_messages(socket) do
    socket
  end

  def assign_presense_id(socket) do
    socket
    |> assign(presense_id: UUID.uuid4())
  end

  defp maybe_subscribe_messages(socket, room_id) do
    if socket |> connected?() do
      Chatrooms.subscribe_messages(room_id)
    end

    socket
  end

  ###########################
  # RENDER
  ###########################

  def render(%{live_action: :index} = assigns) do
    ~H"""
    <div class="flex flex-row h-screen antialiased text-gray-800 w-screen">
      <.live_component module={RoomsComponent} id="room-sidebar" rooms_stream={@streams.rooms} />
      <.live_component module={MessagesComponent} id="messages-page" />
    </div>
    """
  end

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <div class="flex flex-row h-screen antialiased text-gray-800 w-screen">
      <.live_component module={RoomsComponent} id="room-sidebar" rooms_stream={@streams.rooms} />
      <.live_component
        module={MessagesComponent}
        id="messages-page"
        messages_stream={@streams.messages}
        room={@room}
        users_online={length(@presences)}
        users_typing={Presence.get_typing_presences(@presences)}
      />
    </div>
    <ul></ul>
    """
  end

  def handle_event(
        "load-older-messages",
        _params,
        %{assigns: %{room: room, last_message_timestamp: last_message_timestamp}} = socket
      ) do
    {:noreply, socket |> append_messages(room.id, last_message_timestamp)}
  end

  def handle_event(
        "load-older-rooms",
        _params,
        %{assigns: %{last_room_timestamp: last_room_timestamp}} = socket
      ) do
    {:noreply, socket}
  end

  ######################################
  # CODE PUBSUB
  ######################################

  defp update_active_room_upon_edit(%{assigns: %{room: room}} = socket, updated_room)
       when room.id == updated_room.id do
    socket |> assign(:room, updated_room)
  end

  defp update_active_room_upon_edit(socket, _different_room), do: socket

  defp maybe_update_message_stream(
         %{assigns: %{last_message_timestamp: last_message_timestamp}} = socket,
         message
       )
       when last_message_timestamp <= message.inserted_at,
       do: socket |> stream_insert(:messages, message)

  defp maybe_update_message_stream(socket, _msg), do: socket

  defp redirect_room_upon_deleting(%{assigns: %{room: room}} = socket, deleted_room)
       when room.id == deleted_room.id do
    socket
    |> push_navigate(to: ~p"/rooms")
    |> put_flash(:error, "#{room.name} has been deleted.")
  end

  defp redirect_room_upon_deleting(socket, _deleted_room), do: socket
  # Room handling
  def handle_info({:room_created, room}, socket) do
    {:noreply, socket |> stream_insert(:rooms, room, at: 0)}
  end

  def handle_info({:room_deleted, deleted_room}, socket) do
    {:noreply,
     socket
     |> redirect_room_upon_deleting(deleted_room)
     |> stream_delete(:rooms, deleted_room)}
  end

  def handle_info({:room_updated, updated_room}, socket) do
    {:noreply,
     socket
     |> update_active_room_upon_edit(updated_room)
     |> stream_insert(:rooms, updated_room)}
  end

  # message handling

  def handle_info({:message_created, message}, socket) do
    {:noreply, socket |> stream_insert(:messages, message, at: -1)}
  end

  def handle_info({:message_deleted, message}, socket) do
    {:noreply, socket |> stream_delete(:messages, message)}
  end

  def handle_info({:message_updated, message}, socket) do
    {:noreply, socket |> maybe_update_message_stream(message)}
  end

  def handle_info(%{event: "presence_diff", payload: _diff}, %{assigns: %{room: _room}} = socket) do
    {:noreply, socket |> handle_presence_diff()}
  end

  ###########
  # PRESENCE
  ###########

  defp handle_presence_diff(%{assigns: %{room: room}} = socket) when not is_nil(room) do
    socket
    |> assign(presences: Presence.list_room(room.id))
  end

  defp handle_presence_diff(socket), do: socket
end
