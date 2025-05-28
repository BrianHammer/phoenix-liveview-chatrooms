defmodule ChatRoomsWeb.RoomsComponent do
  use Phoenix.LiveComponent
  import ChatRoomsWeb.CoreComponents
  alias ChatRooms.Chatrooms

  defp room_button(assigns) do
    ~H"""
    <div class="overflow-y-auto overflow-x-auto">
      <div class="flex items-center px-4 py-3 cursor-ptr">
        <div class="relative">
          <img
            class="w-10 h-10 rounded-full"
            src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fpetapixel.com%2Fassets%2Fuploads%2F2019%2F02%2Fdownload-2.jpeg&f=1&nofb=1&ipt=2b24f64061e378a80aed9a80daae2041b3d5810724c9ef7022a6ab026e05d9e6"
            alt="User avatar"
          />
          <div class="absolute bottom-0 right-0 w-3 h-3 bg-green-400 border-2 border-gray-900 rounded-full">
          </div>
        </div>
        <div class="ml-3 flex flex-col">
          <.link class="font-bold text-white-700 hover:text-white" patch={"/rooms/#{@room.id}"}>
            {@room.name}
          </.link>
          <div class="flex flex-row items-center gap-2 text-sm text-gray-500 font-medium">
            <button
              phx-target={@myself}
              phx-click="edit-room"
              phx-target-id={@room.id}
              class="hover:text-gray-300 "
              href="#"
            >
              Edit
            </button>
            <button
              class="hover:text-gray-300"
              phx-target={@myself}
              phx-click="delete-room"
              phx-value-id={@room.id}
            >
              Delete
            </button>
          </div>
        </div>
      </div>
      <!-- More user list items here -->
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col flex-shrink-0 w-64 bg-gray-900 text-gray-300">
      <div class="flex flex-col items-center justify-center h-20 border-b border-gray-800">
        <h1 class="text-xl font-bold">Chat Rooms</h1>
        <button>Create New</button>
      </div>

      <ul id="rooms-sidebar-list" phx-update="stream">
        <%= for {dom_id, room} <- @rooms_stream do %>
          <li id={dom_id}>
            <.room_button myself={@myself} room={room} />
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def handle_event("delete-room", %{"id" => id}, socket) do
    {:ok, _} =
      Chatrooms.get_room!(id)
      |> Chatrooms.delete_room()

    {:noreply, socket}
  end
end
