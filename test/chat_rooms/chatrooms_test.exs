defmodule ChatRooms.ChatroomsTest do
  use ChatRooms.DataCase

  alias ChatRooms.Chatrooms

  describe "rooms" do
    alias ChatRooms.Chatrooms.Room

    import ChatRooms.ChatroomsFixtures

    @invalid_attrs %{name: nil}

    test "list_rooms/0 returns all rooms" do
      room = room_fixture()
      assert Chatrooms.list_rooms() == [room]
    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      assert Chatrooms.get_room!(room.id) == room
    end

    test "create_room/1 with valid data creates a room" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Room{} = room} = Chatrooms.create_room(valid_attrs)
      assert room.name == "some name"
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chatrooms.create_room(@invalid_attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = room_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Room{} = room} = Chatrooms.update_room(room, update_attrs)
      assert room.name == "some updated name"
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = room_fixture()
      assert {:error, %Ecto.Changeset{}} = Chatrooms.update_room(room, @invalid_attrs)
      assert room == Chatrooms.get_room!(room.id)
    end

    test "delete_room/1 deletes the room" do
      room = room_fixture()
      assert {:ok, %Room{}} = Chatrooms.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Chatrooms.get_room!(room.id) end
    end

    test "change_room/1 returns a room changeset" do
      room = room_fixture()
      assert %Ecto.Changeset{} = Chatrooms.change_room(room)
    end
  end

  describe "messages" do
    alias ChatRooms.Chatrooms.Message

    import ChatRooms.ChatroomsFixtures

    @invalid_attrs %{text: nil, username: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Chatrooms.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Chatrooms.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{text: "some text", username: "some username"}

      assert {:ok, %Message{} = message} = Chatrooms.create_message(valid_attrs)
      assert message.text == "some text"
      assert message.username == "some username"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chatrooms.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{text: "some updated text", username: "some updated username"}

      assert {:ok, %Message{} = message} = Chatrooms.update_message(message, update_attrs)
      assert message.text == "some updated text"
      assert message.username == "some updated username"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Chatrooms.update_message(message, @invalid_attrs)
      assert message == Chatrooms.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Chatrooms.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Chatrooms.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Chatrooms.change_message(message)
    end
  end
end
