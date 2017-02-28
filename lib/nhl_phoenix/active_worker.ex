defmodule ActiveWorker do
	use GenServer
	require Logger

	@registry_name :game_reg

	def start_link([game_id] = state) do

		# name = "GID#{game_id}"
		# atom = String.to_atom(name)
		GenServer.start_link(__MODULE__, state, name: via_tuple(game_id))
	end

	defp via_tuple(game_id), do: {:via, Registry, {@registry_name, game_id}}

	def init(state) do
		schedule_work()
		{:ok, state}
	end

	def handle_info(:active_work, [game_id] = state) do
		IO.inspect "##########################"
		IO.inspect "Active worker"
		score = get_box_score(game_id) |> parse_response
		IO.inspect score

		NhlPhoenix.Endpoint.broadcast! "room:lobby", "new_msg", %{body: "Active Games Ping", data: score}
		schedule_work()
		{:noreply, state}
	end

	defp schedule_work() do
    Process.send_after(self(), :active_work, 10000) # In 2 hours
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body
    |> JSON.decode!
    body
  end

  def get_box_score(game_id) do
    url = "https://api.fantasydata.net/nhl/v2/json/BoxScore/#{game_id}"
    HTTPoison.get(url, headers, [ ssl: [{:versions, [:'tlsv1.2']}] ])
  end

  def headers do
    ["Ocp-Apim-Subscription-Key": "de3503a074d64b9e8306d1c078c36c5e"]
  end
end
