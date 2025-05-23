defmodule ChatRoomsWeb.RoomsComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <ul class="p-4">
      <%= for room <- @rooms do %>
        <li class="py-2 px-4 bg-red" id={"room-#{room.id}"}>
          <.link href={"/rooms/#{room.id}"}>
            {room.name}
          </.link>
        </li>
      <% end %>
    </ul>
    """
  end
end
