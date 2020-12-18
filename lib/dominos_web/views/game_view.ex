defmodule DominosWeb.GameView do
  use DominosWeb, :view

  def game_owner?(owner_id, owner_id), do: true

  def game_owner?(owner_id, current_user_id), do: false

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
