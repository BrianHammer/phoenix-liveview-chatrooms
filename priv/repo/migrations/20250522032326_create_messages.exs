defmodule ChatRooms.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :username, :string
      add :text, :string

      add :room_id, references(:rooms, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:room_id])
  end
end
