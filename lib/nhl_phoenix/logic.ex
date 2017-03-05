defmodule NhlPhoenix.Logic do
	use GenServer
	require Logger
	import Supervisor.Spec
	import NhlPhoenix.FantasyWrapper

	def start_link(sup) do
		GenServer.start_link(__MODULE__, [sup], name: __MODULE__)
	end

	defmodule State do
    defstruct active: nil, games: nil, team_stats: nil
  end

	def init([sup]) when is_pid(sup) do
		send(self, :start_worker_supervisor)
	  {:ok, sup}
	end

	def set_team_state do
		{:ok, %HTTPoison.Response{body: body, status_code: 200}} = get_team_stats(2017)
		Poison.Parser.parse!(body)
	end

	def handle_info(:start_worker_supervisor, sup) do
    {:ok, in_progress_sup} = Supervisor.start_child(sup, supervisor(NhlPhoenix.ProgressSuper, []))
		{:ok, active_games_sup} = Supervisor.start_child(sup, supervisor(NhlPhoenix.ActiveSuper, []))

		team_stats = set_team_state()

		new_worker(in_progress_sup)

    {:noreply, %State{active: active_games_sup, team_stats: team_stats}}
	end

	def handle_info({:games_are_on, games}, state) do
		games
		|> get_game_ids
		|> start_game_processes(state)

		{:noreply, %{state | games: games}}
	end

	defp get_game_ids(games) do
		Enum.map(games, fn(game) ->
			%{"GameID" => id} = game
			id
		end)
	end

	defp start_game_processes(games, state) do
		Enum.each(games, fn(game_id) ->
			 new_game(state, game_id)
		end)
	end

	defp new_game(state, game_id ) do
		case Supervisor.start_child(state.active, [[game_id, state.team_stats]]) do
	    {:ok, _worker} -> {:ok, game_id}
			{:error, {:already_started, _pid}} -> {:error, :process_already_exists}
      other -> {:error, other}
		end
	end

	defp new_worker(sup) do
    {:ok, _worker} = Supervisor.start_child(sup, [[]])
	end

 end
