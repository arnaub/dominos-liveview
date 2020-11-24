defmodule DominosWeb.GameLive.Index do
  use DominosWeb, :live_view

  alias Dominos.Games
  alias Dominos.Repo

  @impl true
  @spec mount(any, any, Phoenix.LiveView.Socket.t()) ::
          {:ok, Phoenix.LiveView.Socket.t(), [{:temporary_assigns, [...]}, ...]}
  def mount(_params, _session, socket) do
    if connected?(socket), do: Games.subscribe()
    {:ok, assign(socket, :games, list_games()), temporary_assigns: [games: []]}
  end

  @impl true
  def handle_info({:game_created, game}, socket) do
    {:noreply, update(socket, :games, fn games -> [game | games] end)}
  end

  def handle_info({:game_updated, game}, socket) do
    {:noreply, update(socket, :games, fn games -> [game | games] end)}
  end

  def handle_info({:game_deleted, deleted_game}, socket) do
    games = list_games() |> Enum.filter(fn game -> game.id != deleted_game.id end)
    {:noreply, update(socket, :games, games)}
  end

  defp list_games do
    Games.list_games() |> Repo.preload(:user)
  end
end
