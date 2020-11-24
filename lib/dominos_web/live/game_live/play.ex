defmodule DominosWeb.GameLive.Play do
  use DominosWeb, :live_view

  alias Dominos.Play
  alias Dominos.Games

  # @impl true
  def mount(_params, %{"id" => id, "user_id" => user_id}, socket) do
    if connected?(socket), do: DominosWeb.Endpoint.subscribe(topic(id))
    pid = get_pid(id)
    state = Play.get_state(pid)

    {:ok,
     assign(socket,
       state: state,
       current_user_id: user_id,
       game_id: id,
       players_info: players_info(state)
     )}
  end

  def handle_event("play_tile", %{"tile" => tile, "game_id" => game_id, "side" => side}, socket) do
    pid = get_pid(game_id)
    Play.play_tile(pid, format_tile(tile), String.to_atom(side))
    state = Play.get_state(pid)
    IO.inspect(state)
    Phoenix.PubSub.broadcast(Dominos.PubSub, "play:#{game_id}", {:update, game_id})
    {:noreply, assign(socket, state: state)}
  end

  def handle_event("pick_tile", %{"game_id" => game_id}, socket) do
    pid = get_pid(game_id)
    Play.pick_tile(pid)
    state = Play.get_state(pid)
    Phoenix.PubSub.broadcast(Dominos.PubSub, "play:#{game_id}", {:update, game_id})
    {:noreply, assign(socket, state: state)}
  end

  def handle_event("next_round", %{"game_id" => game_id}, socket) do
    pid = get_pid(game_id)
    Play.next_round(pid)
    state = Play.get_state(pid)
    Phoenix.PubSub.broadcast(Dominos.PubSub, "play:#{game_id}", {:update, game_id})
    {:noreply, assign(socket, state: state)}
  end

  def handle_info({:update, game_id}, socket) do
    pid = get_pid(game_id)
    state = Play.get_state(pid)
    {:noreply, assign(socket, state: state, players_info: players_info(state))}
  end

  defp players_info(state) do
    state.players
    |> Enum.sort_by(& &1.id)
    |> Enum.map(fn player ->
      %{
        id: player.id,
        name: player.name,
        tiles_count: player.picked_tiles |> Enum.count(),
        score: player.score,
        player_id: player.player_id
      }
    end)
  end

  defp get_pid(game_id) do
    process_name = String.to_atom("game_#{game_id}")

    case Process.whereis(process_name) do
      nil ->
        game = Games.get_game!(game_id)

        {:ok, pid} =
          DynamicSupervisor.start_child(
            Dominos.GameSupervisor,
            {Dominos.Play, name: process_name}
          )

        Play.setup(pid, game_id, [1, 2], game.state)
        pid

      pid ->
        pid
    end
  end

  defp format_tile(tile) do
    tile
    |> String.split(",")
    |> Enum.map(fn e -> String.to_integer(e) end)
  end

  defp topic(game_id), do: "play:#{game_id}"
end
