defmodule DominosWeb.GameView do
  use DominosWeb, :view

  def game_owner?(owner_id, owner_id), do: true

  def game_owner?(_owner_id, _current_user_id), do: false

  def available_side(_side, [], _tile), do: true

  def available_side(:left, board_tiles, [x_value, y_value]) do
    [value, _] = board_tiles |> Enum.at(0)
    x_value == value || y_value == value
  end

  def available_side(:right, board_tiles, [x_value, y_value]) do
    [_, value] = board_tiles |> Enum.at(-1)
    x_value == value || y_value == value
  end

  def game_ready?(game_id, player_id, game_player_ids) do
    game_owner?(game_id, player_id) && enough_players?(game_player_ids)
  end

  def enough_players?(game_player_ids) do
    game_player_ids |> Enum.count() > 1
  end

  def players_ready(player_ids, players) do
    players |> Enum.filter(fn player -> Enum.member?(player_ids, player.id) end)
  end

  def players_waiting(player_ids, players) do
    players |> Enum.filter(fn player -> !Enum.member?(player_ids, player.id) end)
  end

  def player_state(%{players: players}, current_player_id) do
    players
    |> Enum.filter(fn player -> player.player_id == current_player_id end)
    |> Enum.at(0)
  end

  def player_score(scores_array) do
    scores_array |> Enum.sum()
  end

  def players_by_score(%{players: players}) do
    players
    |> Enum.sort_by(&(&1.score |> Enum.sum()), :asc)
    |> Enum.with_index()
  end

  def disabled?(count) when count < 2 do
    "disabled"
  end

  def disabled?(_count) do
    ""
  end
end
