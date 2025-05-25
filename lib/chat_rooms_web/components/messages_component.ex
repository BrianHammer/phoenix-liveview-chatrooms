defmodule ChatRoomsWeb.MessagesComponent do
  alias ChatRooms.Chatrooms
  use Phoenix.LiveComponent

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{room_id: room_id} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> stream_messages_from_room(room_id)
     |> maybe_subscribe(room_id)}
  end

  def stream_messages_from_room(socket, room_id) do
    messages = socket.assigns[:messages] || Chatrooms.list_all_messages_from_room(room_id)

    socket
    |> stream(:messages, messages)
  end

  def maybe_subscribe(socket, room_id) do
    if connected?(socket), do: Chatrooms.subscribe_messages(room_id)
    socket
  end

  def render(assigns) do
    ~H"""
    <ul class="p-4 border-black" id="messages-list">
      <%= for {dom_id, message} <- @streams.messages do %>
        <li class="py-2 px-4 bg-red" id={dom_id}>
          <b>{message.username}</b>
          <p>{message.text}</p>
          <small>{dom_id}</small>
        </li>
      <% end %>
    </ul>
    """
  end
end
