defmodule Dominos.Games.State do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :board_tiles, {:array, {:array, :integer}}
    field :game_id, :integer
    field :losers, {:array, :integer}
    field :player_turn, :integer
    embeds_many :players, Dominos.Games.Players, on_replace: :delete
    field :remaining_tiles, {:array, {:array, :integer}}
    field :status, :string
    field :winner, :integer
    field :winners, {:array, :integer}
  end

  def changeset(state, attrs) do
    state
    |> cast(attrs, [
      :board_tiles,
      :game_id,
      :losers,
      :player_turn,
      :remaining_tiles,
      :status,
      :winner,
      :winners
    ])
    |> cast_embed(:players)
  end
end
