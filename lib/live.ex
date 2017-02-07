defmodule NhlPhoenix.Live do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: LiveGames)
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    # Do the work you desire here
    IO.inspect "###########################"
    IO.inspect "Server Ping"
    NhlPhoenix.Endpoint.broadcast! "room:lobby", "new_msg", %{body: "Server Ping"}
    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 1000) # In 2 hours
  end
end
