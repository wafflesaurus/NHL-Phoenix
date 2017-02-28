defmodule NhlPhoenix.Logic do
	use GenServer
	require Logger
	import Supervisor.Spec

	@game_reg :game_reg

	def start_link(sup) do
		GenServer.start_link(__MODULE__, [sup], name: __MODULE__)
	end

	defmodule State do
    defstruct active: nil, games: nil
  end

	def init([sup]) when is_pid(sup) do
		send(self, :start_worker_supervisor)
	  {:ok, sup}
	end

	def handle_info(:start_worker_supervisor, sup) do

    {:ok, in_progress_sup} = Supervisor.start_child(sup, supervisor_spec)
		{:ok, active_games_sup} = Supervisor.start_child(sup, other_spec)

		new_worker(in_progress_sup)

    {:noreply, %State{active: active_games_sup}}
	end

	def handle_info({:games_are_on, games}, state) do
		g = get_game_ids(games)
		childs = Supervisor.which_children(state.active)

		Enum.each(g, fn(game_id) ->
			 new_game(state, game_id)
		end)
		{:noreply, %{state | games: games}}
	end

	defp get_game_ids(games) do
		Enum.map(games, fn(game) ->
			%{"GameID" => id} = game
			id
		end)
	end

	defp new_game(state, game_id ) do
		case Supervisor.start_child(state.active, [[game_id]]) do
	    {:ok, worker} -> {:ok, game_id}
			{:error, {:already_started, _pid}} -> {:error, :process_already_exists}
      other -> {:error, other}
		end
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
