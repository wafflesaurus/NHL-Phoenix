defmodule ActiveWorker do
	use GenServer
	import NhlPhoenix.FantasyWrapper
	require Logger

	@registry_name :game_reg

	def start_link([game_id, _team_stats] = state) do
		GenServer.start_link(__MODULE__, state, name: via_tuple(game_id))
	end

	defp via_tuple(game_id), do: {:via, Registry, {@registry_name, game_id}}

	def init(state) do
		schedule_work()
		{:ok, state}
	end

	def handle_info(:active_work, [game_id, team_stats] = state) do
		IO.inspect "##########################"
		IO.inspect "Active worker"
		score = get_box_score(game_id)
		|> parse_response
		if ("foo" in ["foo"] == :false) do
			IO.inspect score["Game"]["HomeTeam"]
		end

		NhlPhoenix.Endpoint.broadcast! "room:lobby", "new_msg", %{body: "Active Games Ping", game_stats: score, team_stats: team_stats}
		schedule_work()
		{:noreply, state}
	end

	defp schedule_work() do
    Process.send_after(self(), :active_work, 10000) # In 2 hours
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body
    |> Poison.Parser.parse!
  end
end
