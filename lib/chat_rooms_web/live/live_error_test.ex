defmodule ChatRoomsWeb.LiveErrorTest do
  use ChatRoomsWeb, :live_view
  import ChatRoomsWeb.CoreComponents

  defp get_group("a"),
    do: [
      %{id: 1, value: "a"},
      %{id: 2, value: "b"}
    ]

  defp get_group("z"),
    do:
      [
        %{id: 3, value: "z"},
        %{id: 4, value: "y"},
        %{id: 5, value: "x"}
      ]
      |> Enum.shuffle()

  defp get_group(_),
    do: []

  def mount(_, _, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _, socket) do
    {:noreply, socket |> stream_group(id)}
  end

  defp stream_group(socket, id) do
    socket
    |> stream(:group, get_group(id), reset: true)
  end

  def render(assigns) do
    ~H"""
    <h1>Replicating error</h1>
    <.link patch="/testing/a">Group ABC</.link>
    <br />
    <.link patch="/testing/z">Group ZYX</.link>
    <br />

    <ul id="testing-list" phx-update="stream">
      <%= for {dom_id, item} <- @streams.group do %>
        <li id={dom_id}>
          {item.value}
        </li>
      <% end %>
    </ul>
    """
  end
end
