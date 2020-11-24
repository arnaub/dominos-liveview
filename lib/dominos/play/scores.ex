defmodule Dominos.Play.Scores do
  alias Dominos.Play.Players

  def calculate_scores(
        %{board_tiles: board_tiles, player_turn: player_turn, players: players} = state,
        play_type
      ) do
    scores_array(state)
    |> apply_scores(player_turn, win_type(board_tiles, play_type))
    |> Enum.with_index()
    |> Enum.map(fn {%{id: id, count: count}, index} ->
      player = Players.find(players, id)

      player
      |> Map.merge(%{
        score: player.score ++ [count],
        round_position: index
      })
    end)
  end

  def win_type(_board_tiles, :doubles) do
    :quadruple
  end

  def win_type(_board_tiles, :closed) do
    :closed
  end

  def win_type(board_tiles, :normal) do
    [left_value, _] = board_tiles |> Enum.at(0)
    [_, right_value] = board_tiles |> Enum.at(-1)

    if left_value == right_value do
      :double
    else
      :normal
    end
  end

  def scores_array(%{players: players, player_turn: player_turn}) do
    scores =
      players
      |> get_scores()
      |> order_scores(player_turn)

    lower_score = scores |> Enum.at(0)
    closed_by_current_player = lower_score.id == player_turn
    define_scores(scores, closed_by_current_player, lower_score.count)
  end

  def apply_scores(scores, player_turn, :closed) do
    lower_score = scores |> Enum.at(0)
    closed_by_current_player = lower_score.id == player_turn
    define_scores(scores, closed_by_current_player, lower_score.count)
  end

  def apply_scores(scores, _player_turn, :normal) do
    define_scores(scores, true, nil)
  end

  def apply_scores(scores, _player_turn, :double) do
    scores |> Enum.map(fn %{count: count} = score -> Map.merge(score, %{count: count * 2}) end)
  end

  def apply_scores(scores, _player_turn, :quadruple) do
    scores |> Enum.map(fn %{count: count} = score -> Map.merge(score, %{count: count * 4}) end)
  end

  def get_scores(players) do
    players
    |> Enum.map(fn player ->
      %{
        id: player.id,
        count:
          Enum.reduce(player.picked_tiles, 0, fn [left_value, right_value], acc ->
            acc + left_value + right_value
          end)
      }
    end)
  end

  def order_scores(scores, player_turn) do
    scores
    |> Enum.sort_by(&abs(&1.id - player_turn))
    |> Enum.sort_by(& &1.count, :asc)
  end

  def define_scores([winner | losers], true, _) do
    winner = winner |> Map.merge(%{count: 0})
    [winner | losers]
  end

  def define_scores(scores, false, lower_score) do
    scores
    |> Enum.map(fn score ->
      if score.count == lower_score do
        %{id: score.id, count: 0}
      else
        score
      end
    end)
  end
end
