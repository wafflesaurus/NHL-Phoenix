defmodule ActiveWorker do
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
		IO.inspect "Active worker"

		NhlPhoenix.Endpoint.broadcast! "room:lobby", "new_msg", %{body: "Active Games Ping"}
		schedule_work()
		{:noreply, state}
	end

	defp schedule_work() do
    Process.send_after(self(), :work, 10000) # In 2 hours
  end

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body
    |> JSON.decode!
    |> are_games_in_progress?
  end

  def are_games_in_progress? do
    url = "https://api.fantasydata.net/nhl/v2/json/AreAnyGamesInProgress"
    HTTPoison.get(url, headers, [ ssl: [{:versions, [:'tlsv1.2']}] ])
  end

  def headers do
    ["Ocp-Apim-Subscription-Key": "de3503a074d64b9e8306d1c078c36c5e"]
  end
end
