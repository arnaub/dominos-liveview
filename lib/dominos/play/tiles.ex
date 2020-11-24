defmodule Dominos.Play.Tiles do
  def generate_tiles do
    for i <- 6..0 do
      generate_tile_array(i)
    end
    |> Enum.concat()
    |> Enum.shuffle()
  end

  def generate_tile_array(number) do
    for i <- number..0 do
      [number, i]
    end
  end

  def pick_tiles do
    tiles = generate_tiles()
    pick_tiles(%{picked_tiles: [], remaining_tiles: tiles}, 6)
  end

  def pick_tiles(%{picked_tiles: picked_tiles, remaining_tiles: [head | tail]}, 0) do
    %{picked_tiles: picked_tiles ++ [head], remaining_tiles: tail}
  end

  def pick_tiles(%{picked_tiles: picked_tiles, remaining_tiles: [head | tail]}, n) do
    pick_tiles(%{picked_tiles: picked_tiles ++ [head], remaining_tiles: tail}, n - 1)
  end

  def big_double(tiles) do
    tiles
    |> Enum.filter(fn [x, y] -> x == y end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.at(0)
  end

  def big_double_value(tiles) do
    case big_double(tiles) do
      nil -> nil
      [x, x] -> x
    end
  end

  def big_tile_value(tiles) do
    tiles
    |> Enum.map(fn [x, y] -> x + y end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.at(0)
  end
end
