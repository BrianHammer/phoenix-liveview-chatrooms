defmodule ChatRooms.Chatrooms.RoomQuery do
  import Ecto.Query

  alias ChatRooms.Chatrooms.Room

  def rooms() do
    from r in Room,
      order_by: [asc: r.inserted_at]
  end

  def limit(query, limit) do
    from q in query, limit: ^limit
  end

  def after_timestamp(query, nil), do: query

  def after_timestamp(query, after_timestamp) do
    from q in query, where: q.inserted_at > ^after_timestamp
  end

  def with_messages(query) do
    from q in query,
      preload: :messages
  end
end
