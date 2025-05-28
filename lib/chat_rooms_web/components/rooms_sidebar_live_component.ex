defmodule ChatRoomsWeb.RoomsSidebarLiveComponent do
  use Phoenix.LiveComponent
  import ChatRoomsWeb.CoreComponents

  defp room_button(assigns) do
    ~H"""
    <div class="overflow-y-auto overflow-x-auto">
      <div class="flex items-center px-4 py-3 hover:bg-gray- cursor-ptr">
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
          <a class="font-bold text-white-700 hover:text-white" href="#">The Room Name</a>
          <div class="flex flex-row items-center gap-2 text-sm text-gray-500 font-medium">
            <a class="hover:text-gray-300" href="#">
              Edit
            </a>
            <a class="hover:text-gray-300" href="#">Delete</a>
          </div>
        </div>
      </div>
      <!-- More user list items here -->
    </div>
    """
  end

  defp sidebar(assigns) do
    ~H"""
    <div class="flex flex-col flex-shrink-0 w-64 bg-gray-900 text-gray-300 hidden md:block">
      <div class="flex flex-col items-center justify-center h-20 border-b border-gray-800">
        <h1 class="text-xl font-bold">Chat Rooms</h1>
        <button>Create New</button>
      </div>
      <.room_button />
      <.room_button />
      <.room_button />
      <.room_button />
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <ul class="p-4" id="rooms" phx-update="stream">
      <%= for {dom_id, room} <- @rooms_stream do %>
        <li class="py-2 px-4 bg-red" id={dom_id}>
          <.link href={"/rooms/#{room.id}"}>
            {room.name} -- {dom_id}
          </.link>
          <.button phx-click="delete-room" phx-value-id={room.id}>
            Delete
          </.button>
        </li>
      <% end %>
    </ul>
    """
  end
end
