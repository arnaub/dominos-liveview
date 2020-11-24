defmodule Dominos.Play.Game.PlayTilesTest do
  use Dominos.DataCase
  alias Dominos.Play.Game
  alias Dominos.Play.Players

  import Dominos.Factory

  setup do
    users = insert_list(2, :user)
    player_ids = users |> Enum.map(fn user -> user.id end)
    game = Game.define_state(player_ids)

    {:ok, game}
  end

  describe "Update turn" do
    test "When is the first turn", game do
      state = Game.update_turn(game)
      player_who_starts = Players.who_starts(state.players)
      player = Players.find(state.players, player_who_starts.id)

      assert state.player_turn == player.id
      assert player.available_moves == [player_who_starts.bigger_tile_value]
    end

    test "When is a middle turn", game do
      players =
        Players.update_player(game.players, 0, %{
          available_moves: [[6, 6]],
          picked_tiles: [[4, 3], [2, 0], [6, 3], [6, 5], [3, 0], [6, 6], [6, 1]]
        })

      state =
        Game.update_state(game, %{
          players: players,
          player_turn: 0,
          board_tiles: [[6, 6], [6, 5]]
        })

      player = Players.find(state.players, 0)

      state = Game.update_turn(state)
      assert state.player_turn == 1
    end
  end
end
