defmodule Tree.Logic do
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
    	{:ok, worker_sup} = Supervisor.start_child(sup, supervisor_spec)
		{:ok, other_sup} = Supervisor.start_child(sup, other_spec)

		IO.inspect "Worker Super"
		IO.inspect worker_sup

		IO.inspect "Other Super"
		IO.inspect other_sup
		new_worker(other_sup)
		new_worker(worker_sup)
    	{:noreply, []}
	end


	defp new_worker(sup) do
    	{:ok, worker} = Supervisor.start_child(sup, [[]])
    	worker
	end

	defp supervisor_spec do
	    # opts = [restart: :temporary]
	    supervisor(Tree.WorkerSuper, [])
	end

	defp other_spec do
	    # opts = [restart: :temporary]
	    supervisor(Tree.OtherSuper, [])
	end

 end
