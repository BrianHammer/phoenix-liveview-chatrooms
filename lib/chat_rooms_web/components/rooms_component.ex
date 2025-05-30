defmodule ChatRoomsWeb.RoomsComponent do
  use Phoenix.LiveComponent
  import ChatRoomsWeb.CoreComponents
  alias Phoenix.LiveView.JS
  alias ChatRoomsWeb.RoomsForm
  alias ChatRooms.Chatrooms

  defp room_button(assigns) do
    ~H"""
    <li id={@id} class="overflow-y-auto overflow-x-auto">
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
          <.custom_room_link room={@room} />
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
    </li>
    """
  end

  defp js_hide_sidebar_on_mobile() do
    JS.add_class("hidden", to: "#sidebar")
  end

  # I use this so that closing the sidebar works only on mobile screens...
  def custom_room_link(%{room: room} = assigns) do
    ~H"""
    <!-- This link hides the sidebar -->
    <.link
      phx-click={js_hide_sidebar_on_mobile()}
      class="block md:hidden font-bold text-white-700 hover:text-white"
      patch={"/rooms/#{@room.id}"}
    >
      {@room.name}
    </.link>
    <!-- This link does not hide the sidebar -->
    <.link
      class="hidden md:block font-bold text-white-700 hover:text-white"
      patch={"/rooms/#{@room.id}"}
    >
      {@room.name}
    </.link>
    """
  end

  def render(assigns) do
    ~H"""
    <div
      id="sidebar"
      class="z-10 w-full h-full absolute md:static md:w-64 hidden md:block flex flex-col flex-shrink-0 bg-gray-900 text-gray-300"
    >
      <button class="md:hidden" phx-click={js_hide_sidebar_on_mobile()}>
        <Heroicons.icon name="x-mark" class="w-8 h-8 relative top-5 left-5" />
      </button>

      <div class="flex flex-col items-center justify-center  border-b border-gray-800 p-4">
        <h1 class="text-3xl font-bold">Chat Rooms</h1>
        <button>Create New</button>

        <.live_component module={RoomsForm} id="room-form-sidebar" />
      </div>

      <ul id="rooms-sidebar-list" phx-update="stream">
        <%= for {dom_id, room} <- @rooms_stream do %>
          <.room_button myself={@myself} room={room} id={dom_id} />
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
