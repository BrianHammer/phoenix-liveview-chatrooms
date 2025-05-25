defmodule ChatRoomsWeb.MessagesComponent do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <ul class="p-4 border-black" id="messages-list" phx-update="stream">
      <%= for {dom_id, message} <- @messages_stream do %>
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
