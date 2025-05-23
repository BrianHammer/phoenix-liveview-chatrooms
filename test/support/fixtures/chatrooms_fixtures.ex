defmodule ChatRooms.ChatroomsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ChatRooms.Chatrooms` context.
  """

  @doc """
  Generate a room.
  """
  def room_fixture(attrs \\ %{}) do
    {:ok, room} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> ChatRooms.Chatrooms.create_room()

    room
  end

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        text: "some text",
        username: "some username"
      })
      |> ChatRooms.Chatrooms.create_message()

    message
  end
end
