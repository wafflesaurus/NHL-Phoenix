defmodule NhlPhoenix.FantasyWrapper do

	def get_games_status do
		url = "https://api.fantasydata.net/nhl/v2/json/AreAnyGamesInProgress"
		api_call(url)
	end

	def get_active_games(date) do
    url = "https://api.fantasydata.net/nhl/v2/json/GamesByDate/#{date}"
    api_call(url)
  end

	def get_box_score_delta(date) do
    url = "https://api.fantasydata.net/nhl/v2/json/BoxScoresDelta/#{date}"
    api_call(url)
  end

	def get_box_score(game_id) do
    url = "https://api.fantasydata.net/nhl/v2/json/BoxScore/#{game_id}"
    api_call(url)
  end

	def get_players_by_team(team) do
    url = "https://api.fantasydata.net/nhl/v2/json/Players/#{team}"
    api_call(url)
  end

	def get_player_stats_by_season(season) do
    url = "https://api.fantasydata.net/nhl/v2/json/PlayerSeasonStats/#{season}"
    api_call(url)
  end

	def get_player_stats_by_id(season, player_id) do
    url = "https://api.fantasydata.net/nhl/v2/json/PlayerSeasonStatsByPlayer/#{season}/#{player_id}"
    api_call(url)
  end

	def get_player_stats_by_team(season, team) do
    url = "https://api.fantasydata.net/nhl/v2/json/PlayerSeasonStatsByTeam/#{season}/#{team}"
    api_call(url)
  end

	def get_player_details_by_id(player_id) do
    url = "https://api.fantasydata.net/nhl/v2/json/Player/#{player_id}"
    api_call(url)
  end

	def get_team_stats(season) do
		url = "https://api.fantasydata.net/nhl/v2/json/TeamSeasonStats/#{season}"
    api_call(url)
	end

	defp headers do
    ["Ocp-Apim-Subscription-Key": "de3503a074d64b9e8306d1c078c36c5e"]
  end

	defp api_call(url) do
		HTTPoison.get(url, headers, [ ssl: [{:versions, [:'tlsv1.2']}] ])
	end

end
