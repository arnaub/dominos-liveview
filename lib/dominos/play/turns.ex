defmodule Dominos.Play.Turns do
  alias Dominos.Play.Game
  alias Dominos.Play.Players
  alias Dominos.Play.Moves

  def first_turn(%{players: players} = state) do
    player = Players.who_starts(players)

    updated_players =
      Players.update_player(players, player.id, %{available_moves: [player.bigger_tile_value]})

    state |> Map.merge(%{players: updated_players, player_turn: player.id})
  end

  def update_turn(%{board_tiles: board_tiles, players: players, player_turn: player_turn} = state) do
    new_turn = rem(player_turn + 1, Enum.count(players))
    player = Players.find(players, new_turn)
    player_available_moves = Moves.available_moves(board_tiles, player.picked_tiles)

    Game.update_state(state, %{
      player_turn: new_turn,
      players:
        Players.update_player(players, new_turn, %{available_moves: player_available_moves})
    })
  end
end
