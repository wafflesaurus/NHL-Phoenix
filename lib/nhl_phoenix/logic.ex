defmodule NhlPhoenix.Logic do
	use GenServer
	import Supervisor.Spec

	def start_link(sup) do
		GenServer.start_link(__MODULE__, [sup], name: __MODULE__)
	end

	def init([sup]) when is_pid(sup) do
		send(self, :start_worker_supervisor)
	   {:ok, sup}
	end

	def handle_info(:start_worker_supervisor, sup) do
		IO.inspect "State"
		IO.inspect sup
    {:ok, in_progress_sup} = Supervisor.start_child(sup, supervisor_spec)
		{:ok, active_games_sup} = Supervisor.start_child(sup, other_spec)

		IO.inspect "In Progress Super"
		IO.inspect in_progress_sup

		IO.inspect "Active Games Super"
		IO.inspect active_games_sup

		new_worker(in_progress_sup)
		new_worker(active_games_sup)
    {:noreply, []}
	end


	defp new_worker(sup) do
    {:ok, worker} = Supervisor.start_child(sup, [[]])
    worker
	end

	defp supervisor_spec do
	  # opts = [restart: :temporary]
	  supervisor(NhlPhoenix.ProgressSuper, [])
	end

	defp other_spec do
	  # opts = [restart: :temporary]
	  supervisor(NhlPhoenix.ActiveSuper, [])
	end

 end
