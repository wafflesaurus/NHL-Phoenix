defmodule ProgressWorker do
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
		IO.inspect "Progress worker"
		p = get_games_status
		|> in_progress?

		# are_games_in_progress?
		NhlPhoenix.Endpoint.broadcast! "room:lobby", "new_msg", %{body: "Are Games in Progress Ping"}
    schedule_work()
		{:noreply, state}
	end

	defp schedule_work() do
    Process.send_after(self(), :work, 10000) # In 2 hours
  end

  defp in_progress?({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    if body do
			# IO.inspect body
			notify_parent(body)
		end
  end

  defp get_games_status do
    url = "https://api.fantasydata.net/nhl/v2/json/AreAnyGamesInProgress"
    HTTPoison.get(url, headers, [ ssl: [{:versions, [:'tlsv1.2']}] ])
  end

	defp notify_parent(body) do
		# GenServer.call(NhlPhoenix.Logic, {:games_are_on, body})
		send(NhlPhoenix.Logic, {:games_are_on, body})
	end


  def headers do
    ["Ocp-Apim-Subscription-Key": "de3503a074d64b9e8306d1c078c36c5e"]
  end

end
