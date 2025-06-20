defmodule ChatRooms.Chatrooms do
  @moduledoc """
  The Chatrooms context.
  """

  import Ecto.Query, warn: false
  alias Phoenix.PubSub
  alias ChatRooms.Chatrooms.MessageQuery
  alias ChatRooms.Chatrooms.RoomQuery
  alias ChatRooms.Repo

  alias ChatRooms.Chatrooms.Room

  @default_query_limit 30

  def get_query_limit(), do: @default_query_limit

  @doc """
  Returns the list of rooms.

  ## Examples

      iex> list_rooms()
      [%Room{}, ...]

  """
  def list_all_rooms do
    RoomQuery.rooms()
    |> Repo.all()
  end

  def list_rooms(after_timestamp \\ nil) do
    RoomQuery.rooms()
    |> RoomQuery.limit(@default_query_limit)
    |> RoomQuery.after_timestamp(after_timestamp)
    |> Repo.all()
  end

  @doc """
  Gets a single room.

  Raises `Ecto.NoResultsError` if the Room does not exist.

  ## Examples

      iex> get_room!(123)
      %Room{}

      iex> get_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_room_with_messages!(id) do
    RoomQuery.rooms()
    |> RoomQuery.with_messages()
    |> Repo.get!(id)
  end

  def get_room!(id) do
    RoomQuery.rooms()
    |> Repo.get!(id)
  end

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
    |> notify_rooms(:room_created)
  end

  @doc """
  Updates a room.

  ## Examples

      iex> update_room(room, %{field: new_value})
      {:ok, %Room{}}

      iex> update_room(room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
    |> notify_rooms(:room_updated)
  end

  @doc """
  Deletes a room.

  ## Examples

      iex> delete_room(room)
      {:ok, %Room{}}

      iex> delete_room(room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room(%Room{} = room) do
    Repo.delete(room)
    |> notify_rooms(:room_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(room)
      %Ecto.Changeset{data: %Room{}}

  """
  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  alias ChatRooms.Chatrooms.Message

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_all_messages do
    MessageQuery.messages()
    |> Repo.all()
  end

  def list_all_messages_from_room(room_id) do
    MessageQuery.messages()
    |> MessageQuery.from_room(room_id)
    |> Repo.all()
  end

  def list_messages_from_room(room_id, before_timestamp \\ nil) do
    MessageQuery.messages()
    |> MessageQuery.from_room(room_id)
    |> MessageQuery.limit(@default_query_limit)
    |> MessageQuery.before(before_timestamp)
    |> Repo.all()
    |> Enum.reverse()
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> notify_messages(:message_created)
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
    |> notify_messages(:message_updated)
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
    |> notify_messages(:message_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  ##########################################################
  ## SUBSUB
  ##########################################################

  def subscribe_rooms() do
    PubSub.subscribe(ChatRooms.PubSub, "rooms")
  end

  def notify_rooms({:ok, message}, event) do
    PubSub.broadcast(ChatRooms.PubSub, "rooms", {event, message})

    {:ok, message}
  end

  def notify_rooms({:error, reason}, _event), do: {:error, reason}

  def subscribe_messages(room_id) do
    PubSub.subscribe(ChatRooms.PubSub, "room-messages:#{room_id}")
  end

  def unsubscribe_messages(room_id) do
    PubSub.unsubscribe(ChatRooms.PubSub, "room-messages:#{room_id}")
  end

  def notify_messages({:ok, %{room_id: room_id} = message}, event) do
    PubSub.broadcast(
      ChatRooms.PubSub,
      "room-messages:#{room_id}",
      {event, message}
    )

    {:ok, message}
  end

  def notify_messages({:error, reason}, _event), do: {:error, reason}

  ######################
  # Building a site
  ######################
end
