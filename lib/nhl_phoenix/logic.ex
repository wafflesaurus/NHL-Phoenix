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
		IO.inspect "State Start Work Super"
		IO.inspect sup
    {:ok, in_progress_sup} = Supervisor.start_child(sup, supervisor_spec)
		{:ok, active_games_sup} = Supervisor.start_child(sup, other_spec)

		IO.inspect "In Progress Super"
		IO.inspect in_progress_sup

		IO.inspect "Active Games Super"
		IO.inspect active_games_sup

		new_worker(in_progress_sup)

    {:noreply, [active: active_games_sup]}
	end

	def handle_info({:games_are_on, games}, state) do
		IO.inspect "MESSAGE RECEIVED"
		Enum.each(games, fn(game_data) ->
			 new_game(state, game_data)
		 end)
		{:noreply, state}
	end

	defp new_game(state, %{"GlobalGameID" => game_id} = game_data ) do
		IO.inspect "/////////////////////////////////////////////////"
		IO.inspect game_id

    {:ok, worker} = Supervisor.start_child(state[:active], [[game_data, game_id]])
		IO.inspect worker
    worker
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
