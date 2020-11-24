defmodule Dominos.Repo.Migrations.AddStateToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :state, :map, default: "{}"
    end
  end
end
