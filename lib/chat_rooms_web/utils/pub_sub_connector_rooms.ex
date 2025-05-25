defmodule ChatRooms.PubSubConnectorRooms do
  use GenServer

  alias ChatRooms.Chatrooms
  # alias Phoenix.PubSub

  ############################################
  ## CLIENT
  ############################################

  def start_link(live_component_pid) do
    IO.puts("GENSERVER CREATED")
    GenServer.start_link(__MODULE__, live_component_pid)
  end

  ############################################
  ## SERVER
  ############################################

  def init(live_component_pid) do
    Process.monitor(live_component_pid)
    Chatrooms.subscribe_rooms()

    {:ok, live_component_pid}
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, pid) do
    {:stop, :normal, pid}
  end

  def handle_info({_event, _message} = msg, live_component_pid) do
    IO.puts("Message received in connector. Sending to livecomponent...")
    IO.inspect(msg)
    IO.puts("live_component_pid...")
    IO.inspect(live_component_pid)
    send(live_component_pid, msg)
    {:noreply, live_component_pid}
  end
end
