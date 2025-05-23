defmodule ChatRooms.Chatrooms.MessageQuery do
  import Ecto.Query

  alias ChatRooms.Chatrooms.Message

  def messages() do
    from m in Message,
      order_by: m.inserted_at
  end

  def from_room(query, room_id) do
    from q in query,
      where: q.room_id == ^room_id
  end

  def from_username(query, username) do
    from q in query,
      where: q.username == ^username
  end
end
