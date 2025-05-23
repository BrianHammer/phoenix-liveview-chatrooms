defmodule ChatRooms.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:rooms, [:name])
  end
end
