defmodule Dominos.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema

  import Ecto.Changeset

  schema "users" do
    field :username, :string, null: false
    pow_user_fields()

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> pow_changeset(attrs)
    |> cast(attrs, [:username])
  end
end
