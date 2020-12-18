defmodule Dominos.Repo.Migrations.AddPlayerIdsToGame do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :player_ids, {:array, :integer}, default: []
    end
  end
end
