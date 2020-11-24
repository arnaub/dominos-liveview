defmodule Dominos.Play.Game do
  alias Dominos.Games
  alias Dominos.Play.Rounds
  alias Dominos.Play.Turns
  alias Dominos.Play.Scores
  alias Dominos.Play.Moves

  def load_game(state) do
    state
  end

  def set_game(game_id, user_ids) do
    Rounds.define_first_round(%{game_id: game_id, user_ids: user_ids})
    |> Turns.first_turn()
  end

  def update_state(state, attrs) do
    state |> Map.merge(attrs)
  end

  def next_round(state) do
    state |> update_state(%{status: "playing"})
  end

  def play_tile(state, tile, side, play_type) do
    case Moves.play_tile(state, tile, side) do
      {:ok, new_state} ->
        IO.inspect(new_state)

        if winner_round?(new_state) do
          IO.inspect("!!!Winner!!!!")

          new_state
          |> update_state(%{
            players: Scores.calculate_scores(new_state, play_type),
            winner: new_state.player_turn,
            status: "waiting"
          })
          |> Rounds.next_round()
          |> save_state()
        else
          if is_closed?(new_state) do
            IO.inspect("!!!Closed!!!!")

            new_state
            |> update_state(%{
              players: Scores.calculate_scores(new_state, :closed),
              status: "waiting"
            })
            |> Rounds.next_round()
            |> save_state()
          else
            Turns.update_turn(new_state)
            |> save_state()
          end
        end

      {:invalid_move, old_state} ->
        old_state
    end
  end

  def pick_tile(state) do
    case Moves.pick_tile(state) do
      {:ok, new_state} -> new_state
      {:next, new_state} -> Turns.update_turn(new_state)
    end
  end

  def winner?(%{players: players}) do
    players
    |> Enum.filter(fn player -> player.score > 100 end)
    |> Enum.count() > 0
  end

  def winner_round?(%{players: players}) do
    players
    |> Enum.filter(fn player -> player.picked_tiles |> Enum.count() == 0 end)
    |> Enum.count() > 0
  end

  defp is_closed?(%{board_tiles: board_tiles}) do
    [left_value, _] = board_tiles |> Enum.at(0)
    [_, right_value] = board_tiles |> Enum.at(-1)
    is_closed?(left_value, right_value, board_tiles)
  end

  defp is_closed?(value, value, board_tiles) do
    board_tiles
    |> Enum.filter(fn [left_value, right_value] -> left_value == value or right_value == value end)
    |> Enum.count() == 7
  end

  defp is_closed?(_left_value, _right_value, _tiles), do: false

  def save_state(%{game_id: game_id} = state) do
    Games.get_game!(game_id)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_embed(:state, state)
    |> Dominos.Repo.update!()

    state
  end
end
