defmodule ChatRoomsWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  alias Phoenix.PubSub

  use Phoenix.Presence,
    otp_app: :chat_rooms,
    pubsub_server: ChatRooms.PubSub

  defp format_presences(presences) do
    presences
    |> Enum.map(fn {_user_id, data} ->
      data[:metas]
      |> List.first()
    end)
  end

  defp get_room_topic_from_id(room_id), do: "chatroom:#{room_id}"

  def track_room(room_id, presence_id) do
    topic = get_room_topic_from_id(room_id)

    PubSub.subscribe(ChatRooms.PubSub, topic)

    {:ok, _} =
      track(self(), topic, presence_id, %{
        presence_id: presence_id,
        is_typing: false
      })
  end

  def untrack_room(room_id, presence_id) do
    topic = get_room_topic_from_id(room_id)

    PubSub.unsubscribe(ChatRooms.PubSub, topic)

    untrack(self(), topic, presence_id)
  end

  def list_room(room_id) do
    room_id
    |> get_room_topic_from_id()
    |> __MODULE__.list()
    |> format_presences()
  end

  def set_user_texting(room_id, presence_id, is_typing?) do
    topic = room_id |> get_room_topic_from_id()
    key = presence_id

    new_metas =
      __MODULE__.get_by_key(topic, key)[:metas]
      |> List.first()
      |> Map.merge(%{is_typing: is_typing?})

    __MODULE__.update(self(), topic, key, new_metas)
  end

  def get_typing_presences(presences) do
    presences
    |> Enum.filter(fn presence -> presence.is_typing end)
  end
end
