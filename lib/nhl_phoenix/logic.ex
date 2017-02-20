defmodule NhlPhoenix.Logic do
	use GenServer
	import Supervisor.Spec

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
		IO.inspect "State Start Work Super"
		IO.inspect sup
    {:ok, in_progress_sup} = Supervisor.start_child(sup, supervisor_spec)
		{:ok, active_games_sup} = Supervisor.start_child(sup, other_spec)

		IO.inspect "In Progress Super"
		IO.inspect in_progress_sup

		IO.inspect "Active Games Super"
		IO.inspect active_games_sup

		new_worker(in_progress_sup)

    {:noreply, %State{active: active_games_sup}}
	end

	def handle_info({:games_are_on, games}, state) do
		IO.inspect "MESSAGE RECEIVED"
		g = get_game_ids(games) |> convert_ids_to_atoms
		IO.inspect g
		childs = Supervisor.which_children(state.active)
		IO.inspect childs
		Enum.each(g, fn(game_id) ->
			 new_game(state, game_id)
		end)
		{:noreply, %{state | games: games}}
	end

	defp get_game_ids(games) do
		Enum.map(games, fn(game) ->
			%{"GlobalGameID" => id} = game
			id
		end)
	end

	defp convert_ids_to_atoms(games) do
		Enum.map(games, fn(id) ->
			name = "#{id}"
			atom = String.to_atom(name)
			atom
		end)
	end

	defp new_game(state, game_id ) do
		IO.inspect "/////////////////////////////////////////////////"
		IO.inspect game_id

    {:ok, worker} = Supervisor.start_child(state.active, [[game_id]])
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