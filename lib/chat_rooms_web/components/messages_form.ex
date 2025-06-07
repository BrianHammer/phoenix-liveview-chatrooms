defmodule ChatRoomsWeb.MessagesForm do
  alias ChatRooms.Chatrooms.Message
  alias ChatRooms.Chatrooms
  use Phoenix.LiveComponent

  import ChatRoomsWeb.CoreComponents

  def mount(socket) do
    {:ok,
     socket
     |> assign_empty_message_form()}
  end

  defp assign_empty_message_form(socket),
    do:
      socket
      |> assign(form: %Message{} |> Chatrooms.change_message(%{}) |> to_form())

  defp clear_message_keep_username_form(socket, %{username: username} = _changeset),
    do:
      socket
      |> assign(form: %Message{} |> Chatrooms.change_message(%{username: username}) |> to_form())

  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        id="messages-form"
        phx-submit="message-submit"
        phx-change="validate"
        phx-target={@myself}
        class="flex flex-row gap-4 items-center px-4 py-2 rounded-xl bg-gray-700 w-full "
      >
        <input id="hidden-room-id" type="hidden" name="message[room_id]" value={@room_id} />

        <div class="flex flex-col md:flex-row gap-4 flex-grow">
          <div class="flex-grow md:w-96 relative">
            <input
              type="text"
              name={@form[:username].name}
              id={@form[:username].id}
              value={Phoenix.HTML.Form.input_value(@form, :username)}
              phx-debounce="750"
              autofocus
              placeholder="Username"
              class={"flex w-full border rounded-xl focus:outline-none pl-4 h-10 bg-gray-600 text-gray-200 placeholder-gray-400 #{if @form[:username].errors != [], do: "border-red-500 border-2 focus:border-red-500"}"}
            />
            <span class="absolute flex items-center justify-center h-full w-12 right-0 top-0 text-gray-400">
              <Heroicons.icon name="user-circle" type="outline" class="w-6 h-6" />
            </span>
            <%= if @form[:username].errors != [] do %>
              <div class="absolute -top-4 left-0 text-xs text-gray-900 bg-red-500 px-2 py-[1px] rounded-xl font-medium">
                <%= for error <- @form[:username].errors do %>
                  <span class="">{translate_error(error)}</span>
                <% end %>
              </div>
            <% end %>
          </div>

          <div class="flex-grow relative w-full">
            <input
              type="text"
              phx-target={@myself}
              name={@form[:text].name}
              id={@form[:text].id}
              value={Phoenix.HTML.Form.input_value(@form, :text)}
              placeholder="Type your message here..."
              phx-debounce="750"
              phx-hook="TypingIndicator"
              data-room-id={@room_id}
              id={"messages-form-#{@room_id}"}
              class={"flex w-full border rounded-xl focus:outline-none pl-4 h-10 bg-gray-600 text-gray-200 placeholder-gray-400 #{if @form[:text].errors != [], do: "border-red-500 focus:border-red-500"}"}
            />
            <span class="absolute flex items-center justify-center h-full w-12 right-0 top-0 text-gray-400">
              <Heroicons.icon name="chat-bubble-bottom-center-text" type="outline" class="w-6 h-6" />
            </span>
            <%= if @form[:text].errors != [] do %>
              <div class="absolute -top-4 left-0 text-xs text-gray-900 bg-red-500 px-2 py-[1px] rounded-xl font-medium">
                <%= for error <- @form[:text].errors do %>
                  <span class="">{translate_error(error)}</span>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>

        <.button
          phx-disable-with="sending..."
          class=" flex items-center justify-center bg-indigo-500 hover:bg-indigo-600 rounded-xl text-white px-4 py-2 flex-shrink-0"
        >
          <span>Send</span>
          <span class="ml-2">
            <Heroicons.icon name="paper-airplane" type="outline" class="w-6 h-6" />
          </span>
        </.button>
      </.form>
    </div>
    """
  end

  def render2(assigns) do
    ~H"""
    <div>
      <.form for={@form} id="messages-form" phx-submit="message-submit" phx-target={@myself}>
        <.input
          label="Username"
          field={@form[:username]}
          type="text"
          placeholder="Your name"
          phx-debounce="250"
          autofocus
        />

        <.input
          label="Message"
          field={@form[:text]}
          type="text"
          placeholder="Your message"
          phx-change="texting"
          phx-throttle="1000"
        />

        <input id="hidden-room-id" type="hidden" name="message[room_id]" value={@room_id} />

        <.button type="submit" class="..." phx-disable-with="Sending...">Send</.button>
      </.form>
    </div>
    """
  end

  defp set_is_texting(socket, old_message, new_message)
       when old_message.text !== new_message.text do
    presence_id = socket.id

    socket
  end

  defp set_is_texting(socket, _msg1, _msg2), do: socket

  def handle_event("texting", _, socket) do
    IO.puts("Texting texting texting")
  end

  def handle_event("validate", %{"message" => params}, socket) do
    form =
      %Message{} |> Chatrooms.change_message(params) |> to_form_with_validation() |> IO.inspect()

    {:noreply,
     socket
     |> assign(:form, form)}
  end

  def handle_event("message-submit", %{"message" => inputs}, socket) do
    case Chatrooms.create_message(inputs) do
      {:error, changeset} ->
        {:noreply, socket |> assign(form: changeset |> to_form_with_validation())}

      {:ok, changeset} ->
        {:noreply, socket |> clear_message_keep_username_form(changeset)}
    end
  end

  def handle_event("typing-changed", %{"is_typing" => is_typing?}, %{room_id: room_id} = socket) do
    # TODO: Update me!
    # Presence.set_user_texting(room_id, socket.id)
    {:noreply, socket}
  end

  defp to_form_with_validation(changeset),
    do: changeset |> Map.put(:action, :validate) |> to_form()
end
