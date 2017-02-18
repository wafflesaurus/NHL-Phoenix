defmodule Worker do
	use GenServer

	def start_link(_) do
		GenServer.start_link(__MODULE__, :ok, [])
	end

	def init(state) do
		schedule_work()
		{:ok, state}
	end

	def handle_info(:work, state) do
		IO.inspect "##########################"
		IO.inspect "worker"
		IO.inspect state
		schedule_work()
		{:noreply, state}
	end

	defp schedule_work() do
	    Process.send_after(self(), :work, 1000) # In 2 hours
	end

end
