defmodule ChatRoomsWeb.RoomsComponent do
  use Phoenix.LiveComponent

  alias ChatRooms.PubSubConnectorRooms
  alias ChatRooms.Chatrooms

  def mount(socket) do
    {:ok, socket |> maybe_subscribe()}
  end

  def update(assigns, socket) do
    IO.puts("@MYSELF")
    IO.puts(assigns[:myself])

    {:ok,
     socket
     |> assign(assigns)
     |> stream_rooms()}
  end

  def stream_rooms(socket) do
    rooms = socket.assigns[:rooms] || Chatrooms.list_rooms()

    socket
    |> stream(:rooms, rooms)
  end

  def maybe_subscribe(socket) do
    if connected?(socket), do: PubSubConnectorRooms.start_link(self())

    socket
  end

  def render(assigns) do
    ~H"""
    <ul class="p-4" id="rooms-list">
      <%= for {dom_id, room} <- @streams.rooms do %>
        <li class="py-2 px-4 bg-red" id={dom_id}>
          <.link href={"/rooms/#{room.id}"}>
            {room.name} -- {dom_id}
          </.link>
        </li>
      <% end %>
    </ul>
    """
  end

  def handle_info({:room_created, room}, socket) do
    IO.inspect("STREAMED UPDATE FROM THE CLIENT")

    {:noreply, socket |> stream_insert(:rooms, room, at: 0)}
  end
end
