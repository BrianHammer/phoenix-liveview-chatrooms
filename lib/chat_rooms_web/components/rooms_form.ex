defmodule ChatRoomsWeb.RoomsForm do
  alias ChatRooms.Chatrooms.Room
  alias ChatRooms.Chatrooms
  use Phoenix.LiveComponent

  import ChatRoomsWeb.CoreComponents

  def mount(socket) do
    {:ok,
     socket
     |> assign_empty_room_form()}
  end

  defp assign_empty_room_form(socket),
    do:
      socket
      |> assign(form: %Room{} |> Chatrooms.change_room(%{}) |> to_form())

  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        id="rooms-form"
        phx-submit="room-submit"
        phx-change="validate"
        phx-target={@myself}
      >
        <.input
          label="name"
          field={@form[:name]}
          type="text"
          placeholder="The name of the new room"
          phx-debounce="750"
        />

        <.button type="submit" class="..." phx-disable-with="Creating...">Create Room</.button>
      </.form>
    </div>
    """
  end

  def handle_event("validate", %{"room" => params}, socket) do
    form =
      %Room{} |> Chatrooms.change_room(params) |> to_form_with_validation()

    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("room-submit", %{"room" => input}, socket) do

    case Chatrooms.create_room(input) do
      {:error, changeset} ->
        {:noreply, socket |> assign(form: changeset |> to_form_with_validation())}

      {:ok, _message} ->
        {:noreply, socket |> assign_empty_room_form()}
    end
  end

  defp to_form_with_validation(changeset),
    do: changeset |> Map.put(:action, :validate) |> to_form()
end
