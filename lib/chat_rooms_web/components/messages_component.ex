defmodule ChatRoomsWeb.MessagesComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <ul class="p-4 border-black">
      <%= for message <- @room.messages do %>
        <li class="py-2 px-4 bg-red" id={"message-#{message.id}"}>
          <b>{message.username}</b>
          <p>{message.text}</p>
        </li>
      <% end %>
    </ul>
    """
  end
end
