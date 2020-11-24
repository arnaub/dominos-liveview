defmodule DominosWeb.GameLive.Show do
  use DominosWeb, :live_view

  alias Dominos.Games
  alias Dominos.Users
  alias Dominos.Play.Game

  alias DominosWeb.Presence

  # @impl true
  def mount(_params, %{"id" => id, "user_id" => user_id}, socket) do
    if connected?(socket), do: DominosWeb.Endpoint.subscribe(topic(id))
    user = Users.get_user!(user_id)
    game = Games.get_game!(id)
    track_user(id, user)
    users = get_game_users(id)
    {:ok, assign(socket, game: game, current_user_id: user_id, users: users)}
  end

  def handle_info(
        %{event: "presence_diff", payload: _payload},
        socket = %{assigns: %{game: game}}
      ) do
    {:noreply, assign(socket, users: get_game_users(game.id))}
  end

  def handle_event("start_game", %{"game_id" => game_id}, socket) do
    game = Games.get_game!(game_id)
    user_ids = get_game_users(game_id) |> Enum.take(4) |> Enum.map(fn user -> user.id end)
    {:ok, pid} = DynamicSupervisor.start_child(Dominos.PlaySupervisor, Dominos.Play)
    # state = Dominos.Play.setup(pid, user_ids)
    string_pid = Game.pid_to_string(pid)

    Games.update_game(game, %{status: "playing", pid: string_pid})
    {:noreply, assign(socket, game: game)}
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
        id: user.id,
        enter_at: :os.system_time(:millisecond)
      }
    )
  end

  defp topic(game_id), do: "game:#{game_id}"
end
