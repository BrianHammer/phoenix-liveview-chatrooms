defmodule ChatRoomsWeb.MessagesComponent do
  use Phoenix.LiveComponent
  import ChatRoomsWeb.CoreComponents

  def render2(assigns) do
    ~H"""
    <ul class="p-4 border-black" id="messages-list" phx-update="stream">
      <%= for {dom_id, message} <- @messages_stream do %>
        <li class="py-2 px-4 bg-red" id={dom_id}>
          <b>{message.username}</b>
          <p>{message.text}</p>
          <small>{message.inserted_at |> display_date()}</small>
          <.button phx u-click="delete-message" phx-value-id={message.id}>
            Delete
          </.button>
        </li>
      <% end %>
    </ul>
    """
  end

  ##############################
  # SIDEBAR / CHATROOMS
  ##############################

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

  defp message_header(assigns) do
    ~H"""
    <div class="p-4 mb-8 flex flex-row items-center justify-between gap-4 bg-gray-900 rounded-xl">
      <h1 class="text-white text-xl font-bold">{@name}</h1>
      <p class="text-emerald-500 text-sm">1 Online</p>
    </div>
    """
  end

  defp message_container(assigns) do
    ~H"""
    <div class="flex flex-col flex-auto bg-gray-800 w-full">
      <div class="flex flex-col flex-auto flex-shrink-0 h-full p-4">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  def message_myself(assigns) do
    ~H"""
    <div class="col-start-6 col-end-13 p-3 rounded-lg">
      <div class="flex items-center justify-start flex-row-reverse">
        <div class="flex items-center justify-center h-10 w-10 rounded-full bg-indigo-500 flex-shrink-0">
          Y
        </div>
        <div class="relative mr-3 text-sm bg-indigo-600 py-2 px-4 shadow rounded-xl">
          <div class="text-white">I'm good, thanks! How about you?</div>
          <div class="absolute text-xs bottom-0 right-0 -mb-5 mr-2 text-gray-500">
            Seen
          </div>
        </div>
      </div>
    </div>
    """
  end

  def message(assigns) do
    ~H"""
    <div id={@id} class="col-start-1 col-end-12 md:col-end-10 lg:col-end-8 rounded-lg">
      <div class="flex flex-row items-start gap-2">
        <div class="flex flex-col gap-1">
          <div class="text-gray-300 font-semibold text-sm">{@message.username}</div>
          <div class="relative text-sm bg-gray-700 py-2 px-4 shadow rounded-xl">
            <div class="text-gray-200">
              {@message.text}
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp message_list(assigns) do
    ~H"""
    <div class="flex flex-col h-full overflow-x-auto mb-4">
      <div class="flex flex-col h-full">
        <ul class="grid grid-cols-12 gap-y-4" id="messages-list" phx-update="stream">
          <%= for {dom_id, message} <- @messages_stream do %>
            <.message message={message} id={dom_id} />
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  defp message_input_form(assigns) do
    ~H"""
    <div class="flex flex-row items-center h-16 rounded-xl bg-gray-700 w-full px-4">
      <div>
        <button class="flex items-center justify-center text-gray-400 hover:text-gray-200">
          <svg
            class="w-5 h-5"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13"
            >
            </path>
          </svg>
        </button>
      </div>
      <div class="flex-grow ml-4">
        <div class="relative w-full">
          <input
            type="text"
            class="flex w-full border rounded-xl focus:outline-none focus:border-indigo-300 pl-4 h-10 bg-gray-600 text-gray-200"
          />
          <button class="absolute flex items-center justify-center h-full w-12 right-0 top-0 text-gray-400 hover:text-gray-200">
            <svg
              class="w-6 h-6"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M14.828 14.828a4 4 0 01-5.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              >
              </path>
            </svg>
          </button>
        </div>
      </div>
      <div class="ml-4">
        <button class="flex items-center justify-center bg-indigo-500 hover:bg-indigo-600 rounded-xl text-white px-4 py-1 flex-shrink-0">
          <span>Send</span>
          <span class="ml-2">
            <svg
              class="w-4 h-4 transform rotate-45 -mt-px"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"
              >
              </path>
            </svg>
          </span>
        </button>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="flex h-screen antialiased text-gray-800">
      <!-- sidebar -->
    <!-- container -->
      <.message_container>
        <.message_header name={@room.name} />
        <.message_list room={@room} messages_stream={@messages_stream} />
        <.message_input_form />
      </.message_container>
    </div>
    """
  end

  defp display_date(dt) do
    "#{dt.hour}:#{dt.minute}:#{dt.second}"
  end
end
