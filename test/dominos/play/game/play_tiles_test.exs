defmodule Dominos.Play.Game.PlayTilesTest do
  use Dominos.DataCase
  alias Dominos.Play.Game
  alias Dominos.Play.Players

  import Dominos.Factory

  setup do
    users = insert_list(2, :user)
    player_ids = users |> Enum.map(fn user -> user.id end)
    game = Game.define_state(player_ids)

    game =
      Game.update_state(game, %{
        player_turn: 0
      })

    {:ok, game}
  end

  describe "User plays a tile" do
    test "When player plays a valid move with empty board", game do
      players =
        Players.update_player(game.players, 0, %{
          available_moves: [[6, 6]],
          picked_tiles: [[4, 3], [2, 0], [6, 3], [6, 5], [3, 0], [6, 6], [6, 1]]
        })

      state =
        Game.update_state(game, %{
          players: players
        })

      state = Game.play_tile(state, [6, 6], :left)
      player = Players.find(state.players, 0)
      assert player.available_moves == []
      assert player.picked_tiles |> Enum.count() == 6
      assert player.picked_tiles |> Enum.member?([6, 6]) == false
      assert state.board_tiles == [[6, 6]]
    end

    test "When player plays a valid move with none empty board", game do
      players =
        Players.update_player(game.players, 0, %{
          available_moves: [[3, 4], [3, 0]],
          picked_tiles: [[3, 4], [2, 0], [6, 2], [6, 1], [3, 0]]
        })

      state =
        Game.update_state(game, %{
          board_tiles: [[3, 6], [6, 6], [6, 5], [5, 5]],
          players: players
        })

      state = Game.play_tile(state, [3, 4], :left)
      player = Players.find(state.players, 0)
      assert player.available_moves == []
      assert player.picked_tiles |> Enum.count() == 4
      assert player.picked_tiles |> Enum.member?([3, 4]) == false
      assert state.board_tiles == [[4, 3], [3, 6], [6, 6], [6, 5], [5, 5]]
    end

    test "When player plays an invalid move", game do
      players =
        Players.update_player(game.players, 0, %{
          available_moves: [[3, 4], [3, 0]],
          picked_tiles: [[3, 4], [2, 0], [6, 2], [6, 1], [3, 0]]
        })

      state =
        Game.update_state(game, %{
          board_tiles: [[3, 6], [6, 6], [6, 5], [5, 5]],
          players: players
        })

      state = Game.play_tile(state, [3, 4], :right)
      player = Players.find(state.players, 0)
      assert player.available_moves == [[3, 4], [3, 0]]
      assert player.picked_tiles |> Enum.count() == 5
      assert player.picked_tiles |> Enum.member?([3, 4]) == true
      assert state.board_tiles == [[3, 6], [6, 6], [6, 5], [5, 5]]
    end

    test "When player plays an external tile", game do
      players =
        Players.update_player(game.players, 0, %{
          available_moves: [[3, 4], [3, 0]],
          picked_tiles: [[3, 4], [2, 0], [6, 2], [6, 1], [3, 0]]
        })

      state =
        Game.update_state(game, %{
          board_tiles: [[3, 6], [6, 6], [6, 5], [5, 5]],
          players: players
        })

      state = Game.play_tile(state, [3, 1], :right)
      player = Players.find(state.players, 0)
      assert player.available_moves == [[3, 4], [3, 0]]
      assert player.picked_tiles |> Enum.count() == 5
      assert player.picked_tiles |> Enum.member?([3, 4]) == true
      assert state.board_tiles == [[3, 6], [6, 6], [6, 5], [5, 5]]

      state = Game.play_tile(state, [3, 1], :left)
      player = Players.find(state.players, 0)
      assert player.available_moves == [[3, 4], [3, 0]]
      assert player.picked_tiles |> Enum.count() == 5
      assert player.picked_tiles |> Enum.member?([3, 4]) == true
      assert state.board_tiles == [[3, 6], [6, 6], [6, 5], [5, 5]]
    end
  end
end
