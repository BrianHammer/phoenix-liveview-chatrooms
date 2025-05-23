defmodule ChatRooms.Chatrooms.RoomQuery do
  import Ecto.Query

  alias ChatRooms.Chatrooms.Room

  def rooms() do
    from r in Room,
      order_by: r.name
  end

  def with_messages(query) do
    from q in query,
      preload: :messages
  end
end
