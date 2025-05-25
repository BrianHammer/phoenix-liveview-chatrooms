defmodule ChatRoomsWeb.RoomsComponent do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <ul class="p-4" id="rooms" phx-update="stream">
      <%= for {dom_id, room} <- @rooms_stream do %>
        <li class="py-2 px-4 bg-red" id={dom_id}>
          <.link href={"/rooms/#{room.id}"}>
            {room.name} -- {dom_id}
          </.link>
        </li>
      <% end %>
    </ul>
    """
  end
end
