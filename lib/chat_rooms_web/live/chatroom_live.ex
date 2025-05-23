defmodule ChatRoomsWeb.ChatroomLive do
  alias ChatRoomsWeb.RoomsForm
  alias ChatRoomsWeb.MessagesComponent
  use ChatRoomsWeb, :live_view

  alias ChatRooms.Chatrooms
  alias ChatRoomsWeb.RoomsComponent
  alias ChatRoomsWeb.MessagesForm

  def mount(%{"room_id" => room_id}, _session, %{assigns: %{live_action: :show}} = socket) do
    {
      :ok,
      socket
      |> assign_rooms()
      |> assign_room_with_messages(room_id)
    }
  end

  def mount(_p, _s, %{assigns: %{live_action: :index}} = socket) do
    {:ok, socket |> assign_rooms()}
  end

  defp assign_rooms(socket), do: socket |> assign(rooms: Chatrooms.list_rooms())

  defp assign_room_with_messages(socket, room_id) do
    socket |> assign(room: Chatrooms.get_room_with_messages!(room_id))
  end

  def render(%{live_action: :index} = assigns) do
    ~H"""
    Select a room <.live_component module={RoomsComponent} id="rooms-list" rooms={@rooms} />
    """
  end

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <.live_component module={RoomsComponent} id="rooms-list" rooms={@rooms} room={@room} />
    <.live_component module={RoomsForm} id="rooms-form" />
    <.live_component module={MessagesComponent} id="messages-display" room={@room} />

    <.live_component module={MessagesForm} id="messages-form" room={@room} />
    """
  end
end
