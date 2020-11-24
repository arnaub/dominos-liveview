defmodule Dominos.Games.Players do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :id, :integer
    field :available_moves, {:array, {:array, :integer}}
    field :name, :string
    field :picked_tiles, {:array, {:array, :integer}}
    field :player_id, :integer
    field :round_position, :integer
    field :score, {:array, :integer}
  end

  def changeset(player, attrs) do
    player
    |> cast(attrs, [
      :id,
      :available_moves,
      :name,
      :picked_tiles,
      :player_id,
      :round_position,
      :score
    ])
  end
end
