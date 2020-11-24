defmodule Dominos.Play.Rounds do
  alias Dominos.Play.Game
  alias Dominos.Play.Tiles
  alias Dominos.Play.Players

  def define_first_round(%{game_id: game_id, user_ids: user_ids}) do
    define_first_round(%{players: [], remaining_tiles: Tiles.generate_tiles()}, user_ids)
    |> Map.merge(%{
      board_tiles: [],
      player_turn: -1,
      status: "playing",
      winners: [],
      losers: [],
      game_id: game_id
    })
  end

  def define_first_round(%{players: players, remaining_tiles: remainging_tiles}, []) do
    %{players: players, remaining_tiles: remainging_tiles}
  end

  def define_first_round(%{players: players, remaining_tiles: tiles}, [user_id | tail] = users) do
    %{picked_tiles: picked_tiles, remaining_tiles: remaining_tiles} =
      Tiles.pick_tiles(%{picked_tiles: [], remaining_tiles: tiles}, 6)

    user = Dominos.Users.get_user!(user_id)

    player = [
      %{
        id: Enum.count(users) - 1,
        player_id: user_id,
        name: user.username,
        picked_tiles: picked_tiles,
        available_moves: [],
        score: [],
        round_position: -1
      }
    ]

    define_first_round(
      %{players: players ++ player, remaining_tiles: remaining_tiles},
      tail
    )
  end

  def next_round(state) do
    case Players.winner(state) do
      {:game_ended, winners: winners, losers: losers} ->
        Game.update_state(state, %{status: "ended", winners: winners, losers: losers})

      _ ->
        apply_next_round(state)
    end
  end

  def apply_next_round(state) do
    new_state =
      Game.update_state(state, %{board_tiles: [], remaining_tiles: Tiles.generate_tiles()})

    player_ids = new_state.players |> Enum.map(fn player -> player.id end)

    new_state = Game.update_state(new_state, distribute_tiles(new_state, player_ids))

    Game.update_state(new_state, %{
      players: set_round_winner(new_state)
    })
  end

  def distribute_tiles(%{players: players, remaining_tiles: remaining_tiles}, []) do
    %{players: players, remaining_tiles: remaining_tiles}
  end

  def distribute_tiles(%{players: players, remaining_tiles: tiles}, [player_id | tail]) do
    %{picked_tiles: picked_tiles, remaining_tiles: remaining_tiles} =
      Tiles.pick_tiles(%{picked_tiles: [], remaining_tiles: tiles}, 6)

    player = Players.find(players, player_id)
    players = Players.update_player(players, player.id, %{picked_tiles: picked_tiles})
    distribute_tiles(%{players: players, remaining_tiles: remaining_tiles}, tail)
  end

  def set_round_winner(%{players: players}) do
    winner = players |> Enum.sort_by(& &1.round_position, :asc) |> Enum.at(0)

    Players.update_player(players, winner.id, %{available_moves: winner.picked_tiles})
  end
end
