defmodule Dominos.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :name, :string
    field :status, :string, default: "waiting"
    field :pid, :string
    embeds_one :state, Dominos.Games.State, on_replace: :delete

    belongs_to :user, Dominos.Users.User

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:name, :status, :pid, :user_id])
    |> cast_embed(:state)
    |> validate_required([:name, :user_id])
  end
end
