defmodule Dominos.Play.Moves do
  alias Dominos.Play.Game
  alias Dominos.Play.Players

  def available_moves(board_tiles, player_tiles) do
    [left_value, _] = board_tiles |> Enum.at(0)
    [_, right_value] = board_tiles |> Enum.at(-1)

    player_tiles
    |> Enum.filter(fn [x, y] ->
      x == left_value or
        x == right_value or
        y == left_value or
        y == right_value
    end)
  end

  def pick_tile(%{remaining_tiles: []} = state) do
    {:next, state}
  end

  def pick_tile(
        %{
          board_tiles: board_tiles,
          remaining_tiles: remaining_tiles,
          players: players,
          player_turn: player_turn
        } = state
      ) do
    player = Players.find(players, player_turn)
    {tile, updated_remaining_tiles} = remaining_tiles |> Enum.shuffle() |> List.pop_at(0)
    picked_tiles = player.picked_tiles ++ [tile]

    {:ok,
     Game.update_state(state, %{
       remaining_tiles: updated_remaining_tiles,
       players:
         Players.update_player(players, player.id, %{
           picked_tiles: picked_tiles,
           available_moves: available_moves(board_tiles, picked_tiles)
         })
     })}
  end

  def play_tile(
        %{player_turn: player_turn, players: players, board_tiles: board_tiles} = state,
        tile,
        side
      ) do
    if valid_move?(state, tile, side) do
      player = Players.find(players, player_turn)

      {:ok,
       Game.update_state(state, %{
         board_tiles: put_tile(board_tiles, tile, side),
         players:
           Players.update_player(players, player.id, %{
             picked_tiles: delete_from_picked_tiles(player.picked_tiles, tile, side),
             available_moves: []
           })
       })}
    else
      {:invalid_move, state}
    end
  end

  defp delete_from_picked_tiles(picked_tiles, [double_x, double_y], :both) do
    List.delete(picked_tiles, double_x) |> List.delete(double_y)
  end

  defp delete_from_picked_tiles(picked_tiles, tile, _side) do
    List.delete(picked_tiles, tile)
  end

  defp is_available_move?(
         %{players: players, player_turn: player_turn},
         tile
       ) do
    player = Players.find(players, player_turn)
    player.available_moves |> Enum.member?(tile)
  end

  defp valid_move?(
         %{board_tiles: []} = state,
         tile,
         _side
       ) do
    is_available_move?(state, tile)
  end

  defp valid_move?(%{board_tiles: board_tiles} = state, tile, :left) do
    [value, _] = board_tiles |> Enum.at(0)
    is_available_move?(state, tile) && tile |> Enum.member?(value)
  end

  defp valid_move?(%{board_tiles: board_tiles} = state, tile, :right) do
    [_, value] = board_tiles |> Enum.at(-1)
    is_available_move?(state, tile) && tile |> Enum.member?(value)
  end

  defp valid_move?(
         %{board_tiles: board_tiles} = state,
         [[x, x] = double_x, [y, y] = double_y],
         :both
       ) do
    [left_value, _] = board_tiles |> Enum.at(0)
    [_, right_value] = board_tiles |> Enum.at(-1)

    is_available_move?(state, double_x) and is_available_move?(state, double_y) and
      (x == left_value or x == right_value) and (y == left_value or y == right_value)
  end

  defp put_tile([], tile, _) do
    [tile]
  end

  defp put_tile(board_tiles, tile, :left) do
    [value, _] = board_tiles |> Enum.at(0)
    swipted_tile = swip_tile(value, tile, :left)
    [swipted_tile] ++ board_tiles
  end

  defp put_tile(board_tiles, tile, :right) do
    [_, value] = board_tiles |> Enum.at(-1)
    swipted_tile = swip_tile(value, tile, :right)
    board_tiles ++ [swipted_tile]
  end

  defp put_tile(board_tiles, [[x, x] = double_x, [y, y] = double_y], :both) do
    [left_value, _] = board_tiles |> Enum.at(0)

    if x == left_value do
      put_tile(board_tiles, double_x, :left)
      |> put_tile(double_y, :right)
    else
      put_tile(board_tiles, double_x, :right)
      |> put_tile(double_y, :left)
    end
  end

  defp swip_tile(value, [value, other_value], :left) do
    [other_value, value]
  end

  defp swip_tile(value, [other_value, value], :left) do
    [other_value, value]
  end

  defp swip_tile(value, [value, other_value], :right) do
    [value, other_value]
  end

  defp swip_tile(value, [other_value, value], :right) do
    [value, other_value]
  end

  defp swip_tile(_, tile, _) do
    tile
  end
end
