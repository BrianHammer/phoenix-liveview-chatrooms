defmodule ChatRooms.Chatrooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    has_many :messages, ChatRooms.Chatrooms.Message

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
