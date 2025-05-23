defmodule ChatRooms.Chatrooms.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :text, :string
    field :username, :string
    belongs_to :room, ChatRooms.Chatrooms.Room

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:username, :text, :room_id])
    |> validate_required([:username, :text, :room_id])
    |> validate_length(:username, min: 4, max: 20)
    |> validate_length(:text, min: 2, max: 150)
    |> assoc_constraint(:room)
  end
end
