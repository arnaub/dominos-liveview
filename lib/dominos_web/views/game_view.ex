defmodule DominosWeb.GameView do
  use DominosWeb, :view

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
