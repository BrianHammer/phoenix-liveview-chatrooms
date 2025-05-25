defmodule ChatRooms.PubSubConnectorRooms do
  use GenServer
  alias Phoenix.LiveView
  alias ChatRooms.Chatrooms
  # alias Phoenix.PubSub

  #################################################
  ## LIVEVIEW PIPE
  #################################################
  def maybe_subscribe(%{root_pid: _pid, assigns: %{myself: _cid} = _assigns} = socket) do
    IO.puts("Ran connecting...")

    if LiveView.connected?(socket),
      do: socket |> start_link()

    socket
  end

  ############################################
  ## "CLIENT"
  ############################################
  # def start_link(pid, cid) do
  #  IO.puts("GENSERVER CREATED")
  #  GenServer.start_link(__MODULE__, {pid, cid})
  # end

  def start_link(%{root_pid: pid, assigns: %{myself: cid}} = socket) do
    GenServer.start_link(__MODULE__, {pid, cid, socket})
  end

  ############################################
  ## SERVER
  ############################################

  def init({pid, cid, socket}) do
    IO.puts("Ran init")
    {:ok, {pid, cid, socket}, {:continue, :subscribe}}
  end

  def handle_continue(:subscribe, state) do
    IO.puts("subscribed to room")
    Chatrooms.subscribe_rooms()

    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, pid) do
    {:stop, :normal, pid}
  end

  def handle_info({_event, _message} = msg, {pid, cid, assigns}) do
    IO.puts("HandleInfo called...")
    # send(live_component_pid, msg)
    new_assigns = assigns |> Map.put(:event, msg)
    Phoenix.LiveView.send_update(pid, cid, new_assigns)
    {:noreply, {pid, cid}}
  end
end
