defmodule DominosWeb.GameLive.Show do
  use DominosWeb, :live_view

  alias Dominos.Games
  alias Dominos.Users
  alias Dominos.Play.Game

  alias DominosWeb.Presence

  import DominosWeb.GameView,
    only: [players_ready: 2, players_waiting: 2, game_owner?: 2, game_ready?: 3]

  @impl true
  def mount(_params, %{"id" => id, "user_id" => user_id}, socket) do
    game = Games.get_game!(id)

    case game.status do
      "playing" ->
        {:ok, redirect(socket, to: Routes.game_play_path(socket, :play, game))}

      _ ->
        if connected?(socket), do: DominosWeb.Endpoint.subscribe(topic(id))
        user = Users.get_user!(user_id)
        track_user(id, user)
        users = get_game_users(id)

        {:ok,
         assign(socket,
           game_name: game.name,
           game_id: game.id,
           owner_id: game.user_id,
           current_user_id: user_id,
           users: users,
           game_player_ids: game.player_ids
         )}
    end
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: _payload},
        socket = %{assigns: %{game_id: game_id}}
      ) do
    {:noreply, assign(socket, users: get_game_users(game_id))}
  end

  @impl true
  def handle_info({:update_player_ids, game_player_ids}, socket) do
    {:noreply, assign(socket, game_player_ids: game_player_ids)}
  end

  def handle_info({:start_game, game}, socket) do
    {:noreply, redirect(socket, to: Routes.game_play_path(socket, :play, game))}
  end

  @impl true
  def handle_event("add_player", %{"player_id" => player_id}, socket) do
    add_player_to_game(player_id, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove_player", %{"player_id" => player_id}, socket) do
    remove_player_from_game(player_id, socket)
    {:noreply, socket}
  end

  @impl true
  def handle_event("start_game", _params, socket) do
    game = game_from_socket(socket)

    case Games.update_game(game, %{status: "playing"}) do
      {:ok, game_updated} ->
        Games.broadcast(topic(game_updated.id), :start_game, game_updated)
    end

    {:noreply, socket}
  end

  defp game_from_socket(socket) do
    Games.get_game!(socket.assigns.game_id)
  end

  defp remove_player_from_game(player_id, socket) do
    game = game_from_socket(socket)

    player_ids =
      game.player_ids |> Enum.filter(fn id -> id != player_id |> String.to_integer() end)

    {:ok, updated_game} = Games.update_game(game, %{player_ids: player_ids})
    Games.broadcast(topic(game.id), :update_player_ids, updated_game.player_ids)
  end

  defp add_player_to_game(player_id, socket) do
    game = game_from_socket(socket)

    case game.player_ids |> Enum.count() > 3 do
      true ->
        game.player_ids

      false ->
        {:ok, updated_game} =
          Games.update_game(game, %{
            player_ids: (game.player_ids ++ [player_id |> String.to_integer()]) |> Enum.uniq()
          })

        Games.broadcast(topic(game.id), :update_player_ids, updated_game.player_ids)
    end
  end

  defp get_game_users(game_id) do
    users =
      Presence.list(topic(game_id))
      |> Enum.map(fn {_user_id, data} ->
        data[:metas]
        |> List.first()
      end)
      |> Enum.sort_by(& &1.enter_at, :asc)

    users
  end

  defp track_user(id, user) do
    Presence.track(
      self(),
      topic(id),
      user.id,
      %{
        email: user.email,
        username: user.username,
        id: user.id,
        enter_at: :os.system_time(:millisecond)
      }
    )
  end

  defp topic(game_id), do: "game:#{game_id}"
end
