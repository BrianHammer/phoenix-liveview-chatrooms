defmodule ChatRoomsWeb.MessagesComponent do
  use Phoenix.LiveComponent
  import ChatRoomsWeb.CoreComponents

  alias Phoenix.LiveView.JS
  alias ChatRooms.Chatrooms

  ##############################
  # SIDEBAR / CHATROOMS
  ##############################

  defp js_show_sidebar_on_mobile() do
    JS.remove_class("hidden", to: "#sidebar")
  end

  defp message_header(assigns) do
    ~H"""
    <div class="p-4 mb-8 flex flex-row items-center justify-between gap-4 bg-gray-900 rounded-xl">
      <button class="block md:hidden" phx-click={js_show_sidebar_on_mobile()}>
        <Heroicons.icon name="bars-3" class="w-8 h-8 text-gray-300" />
      </button>
      <h1 class="text-white text-xl font-bold">{@name}</h1>
      <p :if={assigns[:online]} class="text-emerald-500 text-md font-bold">{@online} Online</p>
    </div>
    """
  end

  defp message_container(assigns) do
    ~H"""
    <div class="flex flex-col h-full bg-gray-800 p-4 w-full relative">
      <div class="flex flex-col h-full">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  # I am not using this component
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
      <div class="flex flex-col items-start justify-start gap-1">
        <div class="flex flex-row gap-2 items-center">
          <div class="text-gray-300 font-semibold text-sm">{@message.username}</div>
          <span class="text-sm text-gray-400">{@message.inserted_at |> display_date()}</span>
          <span :if={@message.updated_at != @message.inserted_at} class="text-xs text-gray-500">
            Edited on {@message.updated_at |> display_date()}
          </span>
        </div>
        <div
          id={get_text_id_from_dom_id(@id)}
          class="text-md bg-gray-700 py-2 px-4 shadow rounded-xl text-gray-200 break-all"
        >
          {@message.text}
        </div>
        <div id={get_edit_message_form_id_from_id(@id)} class="hidden">
          <.message_edit_form dom_id={@id} message={@message} myself={@myself} />
        </div>
        <div class="flex flex-row gap-2 items-center font-semibold text-sm">
          <button phx-target={@myself} phx-value-id={@message.id} phx-click="delete-message">
            <Heroicons.icon name="trash" class="w-5 h-5 text-gray-500 hover:text-red-500" />
          </button>
          <button
            id={get_edit_button_id_from_id(@id)}
            phx-target={@myself}
            phx-value-id={@id}
            phx-click={toggle_edit_message_form(@id)}
            class="text-gray-500 hover:text-blue-300"
          >
            <Heroicons.icon name="pencil-square" class="w-54 h-5" />
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp get_text_id_from_dom_id(id), do: "#{id}-text"
  defp get_edit_message_form_id_from_id(id), do: "#{id}-edit-form"
  defp get_edit_button_id_from_id(id), do: "#{id}-edit-button"

  defp toggle_edit_message_form(id) do
    JS.toggle(to: "##{id |> get_text_id_from_dom_id()}")
    |> JS.toggle(to: "##{id |> get_edit_message_form_id_from_id()}")
    |> JS.toggle_class("text-purple-500", to: "##{id |> get_edit_button_id_from_id()}")
  end

  defp message_edit_form(%{message: _room} = assigns) do
    ~H"""
    <.simple_form
      for={@message |> Chatrooms.change_message(%{})}
      phx-submit="update-message"
      phx-target={@myself}
      class="flex items-center max-w-full flex-row gap-2 "
    >
      <input type="hidden" name="username" value={@message.username} />
      <input type="hidden" name="room_id" value={@message.room_id} />
      <input type="hidden" name="message_id" value={@message.id} />
      <input
        autocomplete="off"
        type="text"
        name="text"
        value={@message.text}
        class="bg-gray-700 text-gray-300 flex-grow min-w-50 rounded-xl overflow-x-auto"
      />
      <.button class="" phx-disable-with="Editing..." phx-click={toggle_edit_message_form(@dom_id)}>
        Edit
      </.button>
    </.simple_form>
    """
  end

  defp message_list(assigns) do
    ~H"""
    <div class="h-full overflow-y-auto py-4">
      <.button
        :if={@messages_stream.inserts |> length() >= Chatrooms.get_query_limit()}
        phx-click="load-older-messages"
        class="w-full my-12"
      >
        Load Previous Messages...
      </.button>
      <!-- Ensure full height -->
      <ul class="grid grid-cols-12 gap-y-4" id="messages-list" phx-update="stream">
        <%= for {dom_id, message} <- @messages_stream do %>
          <.message myself={@myself} message={message} id={dom_id} />
        <% end %>
      </ul>
    </div>
    """
  end

  defp users_typing_display(assigns) do
    ~H"""
    <div class=" -top-10 p-2 text-gray-500 text-sm font-bold">
      {show_texters(@users_typing)}
    </div>
    """
  end

  defp show_texters([]), do: ""

  defp show_texters([_presence]) do
    "1 user is typing..."
  end

  defp show_texters(presences) do
    "#{presences |> length()} users are typing..."
  end

  def render(%{room: _room, messages_stream: _messages_stream} = assigns) do
    ~H"""
    <div class="flex flex-col h-full w-full">
      <.message_container>
        <.message_header online={@users_online} name={@room.name} />
        <.message_list myself={@myself} room={@room} messages_stream={@messages_stream} />
        <.users_typing_display users_typing={@users_typing} />
        <.live_component
          module={ChatRoomsWeb.MessagesForm}
          id="main-messages-form"
          room_id={@room.id}
        />
      </.message_container>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col h-full w-full">
      <.message_container>
        <.message_header name="Select or create a room" />

        <div class="my-auto">
          <.live_component module={ChatRoomsWeb.RoomsForm} id="empty-messages-room-create-form" />
        </div>
      </.message_container>
    </div>
    """
  end

  def handle_event("update-message", params, socket) do
    message = Chatrooms.get_message!(params["message_id"])

    case Chatrooms.update_message(message, params |> Map.put("id", params["message_id"])) do
      {:ok, _message} ->
        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("delete-message", %{"id" => id}, socket) do
    {:ok, _} =
      Chatrooms.get_message!(id)
      |> Chatrooms.delete_message()

    {:noreply, socket}
  end

  defp display_date(dt) do
    "#{dt.hour |> Integer.to_string() |> String.pad_leading(2, "0")}:#{dt.minute |> Integer.to_string() |> String.pad_leading(2, "0")}:#{dt.second |> Integer.to_string() |> String.pad_leading(2, "0")}"
  end
end
