defmodule Dominos.Factory do
  use ExMachina.Ecto, repo: Dominos.Repo
  use Dominos.UserFactory
end
