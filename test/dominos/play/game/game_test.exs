defmodule Dominos.Play.Game.GameTest do
  use Dominos.DataCase

  import Dominos.Factory

  describe "Initialize a game" do
    alias Dominos.Play.Game

    test "Create a game with correct default params" do
      users = insert_list(2, :user)
      player_ids = users |> Enum.map(fn user -> user.id end)
      game = Game.define_state(player_ids)

      assert(game.board_tiles == [])
      assert game.remaining_tiles |> Enum.count() == 14
      assert game.player_turn == -1
    end

    test "Create a game with the correct players" do
      users = insert_list(2, :user)
      player_ids = users |> Enum.map(fn user -> user.id end)
      game = Game.define_state(player_ids)

      game_player_ids = game.players |> Enum.map(fn player -> player.player_id end)
      assert game_player_ids -- player_ids == []

      game.players
      |> Enum.each(fn player ->
        assert player.picked_tiles |> Enum.count() == 7
        assert player.available_moves == []
      end)
    end
  end
end
