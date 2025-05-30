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
        class="flex flex-col gap-4 p-4"
      >
        <div class="flex-grow relative w-full">
          <input
            type="text"
            name={@form[:name].name}
            id={@form[:name].id}
            value={Phoenix.HTML.Form.input_value(@form, :name)}
            placeholder="New room name..."
            phx-debounce="750"
            class={"flex w-full border rounded-xl focus:outline-none pl-4 h-10 bg-gray-600 text-gray-200 placeholder-gray-400 #{if @form[:name].errors != [], do: "border-red-500 focus:border-red-500"}"}
          />
          <span class="absolute flex items-center justify-center h-full w-12 right-0 top-0 text-gray-400">
            <Heroicons.icon name="user-group" type="outline" class="w-6 h-6" />
          </span>
          <%= if @form[:name].errors != [] do %>
            <div class="absolute -top-4 left-0 text-xs text-gray-900 bg-red-500 px-2 py-[1px] rounded-xl font-medium">
              <%= for error <- @form[:name].errors do %>
                <span class="">{translate_error(error)}</span>
              <% end %>
            </div>
          <% end %>
        </div>
        <.button class="bg-red-500" type="submit" class="..." phx-disable-with="Creating...">
          Create Room
        </.button>
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
        {:noreply,
         socket
         |> assign(form: changeset |> to_form_with_validation())}

      {:ok, room} ->
        {:noreply, socket |> assign_empty_room_form() |> push_patch(to: "/rooms/#{room.id}")}
    end
  end

  defp to_form_with_validation(changeset),
    do: changeset |> Map.put(:action, :validate) |> to_form()
end
