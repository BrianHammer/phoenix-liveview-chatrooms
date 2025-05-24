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
     |> assign_messages_from_room(room_id)
     |> maybe_subscribe(room_id)}
  end

  def assign_messages_from_room(socket, room_id) do
    messages = socket.assigns[:messages] || Chatrooms.list_all_messages_from_room(room_id)

    socket
    |> assign(messages: messages)
  end

  def maybe_subscribe(socket, room_id) do
    if connected?(socket), do: Chatrooms.subscribe_messages(room_id)
    socket
  end

  def render(assigns) do
    ~H"""
    <ul class="p-4 border-black">
      <%= for message <- @messages do %>
        <li class="py-2 px-4 bg-red" id={"message-#{message.id}"}>
          <b>{message.username}</b>
          <p>{message.text}</p>
        </li>
      <% end %>
    </ul>
    """
  end
end
