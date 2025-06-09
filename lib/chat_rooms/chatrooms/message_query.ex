defmodule ChatRooms.Chatrooms.MessageQuery do
  import Ecto.Query

  alias ChatRooms.Chatrooms.Message

  def messages() do
    from m in Message,
      order_by: [desc: m.inserted_at]
  end

  def limit(query, limit \\ 30) do
    from q in query,
      limit: ^limit
  end

  def before(query, before_timestamp) when is_nil(before_timestamp), do: query

  def before(query, before_timestamp) do
    from q in query,
      where: q.inserted_at < ^before_timestamp
  end

  def from_room(query, room_id) do
    from q in query,
      where: q.room_id == ^room_id,
      order_by: q.inserted_at
  end

  def from_username(query, username) do
    from q in query,
      where: q.username == ^username
  end
end
