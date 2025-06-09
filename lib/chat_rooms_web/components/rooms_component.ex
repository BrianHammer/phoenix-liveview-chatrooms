defmodule ChatRoomsWeb.RoomsComponent do
  use Phoenix.LiveComponent
  import ChatRoomsWeb.CoreComponents
  alias Phoenix.LiveView.JS
  alias ChatRoomsWeb.RoomsForm
  alias ChatRooms.Chatrooms

  defp room_button(assigns) do
    ~H"""
    <li id={@id} class="overflow-y-auto overflow-x-auto">
      <div class="flex items-center px-4 py-3">
        <div class="relative">
          <img
            class="w-10 h-10 rounded-full"
            src="https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ficon-library.com%2Fimages%2Fgroup-icon-flat%2Fgroup-icon-flat-10.jpg&f=1&nofb=1&ipt=22f11bb5d0ad1273788e72b9ec5bab48a8c61ca951994255621fbd5af86fe15f"
            alt="User avatar"
          />
          <div
            hidden
            class="absolute bottom-0 right-0 w-3 h-3 bg-green-400 border-2 border-gray-900 rounded-full"
          >
          </div>
        </div>
        <div class="ml-3 flex flex-col gap-1">
          <div id={@id |> get_text_id_from_id()} class="">
            <.custom_room_link room={@room} />
          </div>

          <div id={@id |> get_input_id_from_id()} class="hidden">
            <.room_edit_form room={@room} myself={@myself} dom_id={@id} />
          </div>

          <div class="flex flex-row items-center gap-2 text-sm text-gray-500 font-medium">
            <button
              class="hover:text-gray-300"
              phx-target={@myself}
              phx-click="delete-room"
              phx-value-id={@room.id}
            >
              <Heroicons.icon name="trash" class="w-5 h-5 text-gray-500 hover:text-red-500" />
            </button>
            <button
              id={get_edit_button_id_from_id(@id)}
              phx-target={@myself}
              phx-click={js_toggle_edit_room_form(@id)}
              class="text-gray-500 hover:text-blue-300"
            >
              <Heroicons.icon name="pencil-square" class="w-54 h-5" />
            </button>
          </div>
        </div>
      </div>
      <!-- More user list items here -->
    </li>
    """
  end

  defp room_edit_form(assigns) do
    ~H"""
    <.simple_form
      for={@room |> Chatrooms.change_room(%{})}
      phx-submit="update-room"
      phx-target={@myself}
      class="flex items-center max-w-full flex-row gap-2 "
    >
      <input type="hidden" name="room_id" value={@room.id} />
      <input
        type="text"
        name="name"
        value={@room.name}
        class="bg-gray-700 text-gray-300 flex-grow md:w-20 rounded-xl p-1"
      />
      <.button class="" phx-disable-with="Editing..." phx-click={js_toggle_edit_room_form(@dom_id)}>
        Edit
      </.button>
    </.simple_form>
    """
  end

  defp get_text_id_from_id(id), do: "#{id}-text"
  defp get_input_id_from_id(id), do: "#{id}-input"
  defp get_edit_button_id_from_id(id), do: "#{id}-edit-button"

  defp js_toggle_edit_room_form(id) do
    JS.toggle(to: "##{id |> get_text_id_from_id()}")
    |> JS.toggle(to: "##{id |> get_input_id_from_id()}")
    |> JS.toggle_class("text-purple-500", to: "##{id |> get_edit_button_id_from_id}")
  end

  defp js_hide_sidebar_on_mobile() do
    JS.add_class("hidden", to: "#sidebar")
  end

  # I use this so that closing the sidebar works only on mobile screens...
  def custom_room_link(%{room: _room} = assigns) do
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
    <div id="sidebar" class="z-10 absolute static hidden w-full md:w-96 h-full md:static md:block">
      <div class="w-full md:w-full h-full flex flex-col bg-gray-900 text-gray-300">
        <button class="md:hidden" phx-click={js_hide_sidebar_on_mobile()}>
          <Heroicons.icon name="x-mark" class="w-8 h-8 relative top-5 left-5" />
        </button>
        <div class="flex flex-col items-center justify-center border-b border-gray-800 p-4 ">
          <h1 class="text-3xl font-bold">Chat Rooms</h1>
          <p>Create New</p>

          <.live_component module={RoomsForm} id="room-form-sidebar" />
        </div>

        <div class="flex-1 overflow-y-auto">
          <ul id="rooms-list" class="space-y-2 p-2" phx-update="stream">
            <%= for {dom_id, room} <- @rooms_stream do %>
              <.room_button myself={@myself} room={room} id={dom_id} />
            <% end %>
            <.button :if={length(@rooms_stream.inserts) >= 15} phx-click="load-older-rooms">
              Load more rooms...
            </.button>
          </ul>
        </div>
      </div>
    </div>
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

      <div class="flex flex-col items-center justify-center border-b border-gray-800 p-4 ">
        <h1 class="text-3xl font-bold">Chat Rooms</h1>
        <button>Create New</button>

        <.live_component module={RoomsForm} id="room-form-sidebar" />
      </div>

      <div class="
      flex-1 overflow-y-auto">
        <!-- Changed this line -->
        <ul id="rooms-sidebar-list" phx-update="stream" class="h-full">
          <%= for {dom_id, room} <- @rooms_stream do %>
            <.room_button myself={@myself} room={room} id={dom_id} />
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  @spec handle_event(<<_::88>>, map(), any()) :: {:noreply, any()}
  def handle_event("update-room", params, socket) do
    rooms = Chatrooms.get_room!(params["room_id"])

    case rooms |> Chatrooms.update_room(params |> Map.put("id", params["room_id"])) do
      {:ok, _room} ->
        {:noreply, socket}

      {:error, _message} ->
        {:noreply, socket}
    end
  end

  def handle_event("delete-room", %{"id" => id}, socket) do
    {:ok, _} =
      Chatrooms.get_room!(id)
      |> Chatrooms.delete_room()

    {:noreply, socket}
  end
end
