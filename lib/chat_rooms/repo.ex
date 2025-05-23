defmodule ChatRooms.Repo do
  use Ecto.Repo,
    otp_app: :chat_rooms,
    adapter: Ecto.Adapters.Postgres
end
