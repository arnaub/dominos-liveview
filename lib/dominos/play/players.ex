defmodule Dominos.Play.Players do
  alias Dominos.Play.Tiles

  def find(players, id) do
    players
    |> Enum.filter(fn player -> player.id == id end)
    |> Enum.at(0)
  end

  def who_starts(players) do
    case player = player_biggest_double(players) do
      nil -> player_biggest_tile(players)
      _ -> player
    end
  end

  def player_biggest_double(players) do
    players
    |> Enum.map(fn player ->
      %{id: player.id, bigger_tile_value: Tiles.big_double(player.picked_tiles)}
    end)
    |> Enum.filter(fn player -> player.bigger_tile_value != nil end)
    |> Enum.sort_by(& &1.bigger_tile_value, :desc)
    |> Enum.at(0)
  end

  def player_biggest_tile(players) do
    players
    |> Enum.map(fn player ->
      %{id: player.id, bigger_tile_value: Tiles.big_tile_value(player.picked_tiles)}
    end)
    |> Enum.filter(fn player -> player.bigger_tile_value != nil end)
    |> Enum.sort_by(& &1.bigger_tile_value, :desc)
    |> Enum.at(0)
  end

  def update_all_players(players, attrs) do
    players
    |> Enum.map(fn player -> player |> Map.merge(attrs) end)
  end

  def update_player(players, id, attrs) do
    current_player = find(players, id)

    other_players =
      players
      |> Enum.filter(fn player -> player.id != id end)

    [current_player |> Map.merge(attrs) | other_players]
  end

  def winner(%{players: players}) do
    player_scores =
      players
      |> Enum.map(fn player ->
        %{player_id: player.player_id, score: player.score |> Enum.sum()}
      end)

    final_scores(player_scores)
  end

  def final_scores(player_scores) do
    if player_scores |> Enum.filter(fn player -> player.score > 100 end) |> Enum.count() > 0 do
      min_score = player_scores |> Enum.min_by(& &1.score)
      max_score = player_scores |> Enum.max_by(& &1.score)

      {:game_ended,
       winners:
         player_scores
         |> Enum.filter(fn player -> player.score == min_score end)
         |> Enum.map(fn player -> player.player_id end),
       losers:
         player_scores
         |> Enum.filter(fn player -> player.score == max_score end)
         |> Enum.map(fn player -> player.player_id end)}
    else
      {:game_in_progress, winners: [], losers: []}
    end
  end
end
