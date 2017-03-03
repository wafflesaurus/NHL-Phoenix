defmodule ProgressWorker do
	use GenServer
	import NhlPhoenix.FantasyWrapper

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
		get_games_status
		|> in_progress?

		# are_games_in_progress?
		# NhlPhoenix.Endpoint.broadcast! "room:lobby", "new_msg", %{body: "Are Games in Progress Ping"}
    schedule_work()
		{:noreply, state}
	end

	defp schedule_work() do
    Process.send_after(self(), :work, 10000) # In 2 hours
  end

  defp in_progress?({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    # if body == "true" do
			get_current_date
			|> get_active_games
			|> todays_games
			|> notify_parent
		# end
  end

	defp get_current_date do
		date = DateTime.utc_now
		ymd = "#{date.year}-#{date.month}-#{date.day}"
		ymd
	end

	defp todays_games({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
	  body
		|> JSON.decode!
  end

	defp notify_parent(body) do
		send(NhlPhoenix.Logic, {:games_are_on, body})
	end

end
