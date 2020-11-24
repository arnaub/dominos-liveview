defmodule DominosWeb.GameController do
  use DominosWeb, :controller
  import Phoenix.LiveView.Controller

  alias Dominos.Games
  alias Dominos.Games.Game

  def index(conn, _params) do
    current_user = Pow.Plug.current_user(conn)
    live_render(conn, DominosWeb.GameLive.Index, session: %{"user_id" => current_user.id})

    # render(conn, "index.html", games: games)
  end

  def new(conn, _params) do
    current_user = Pow.Plug.current_user(conn)
    changeset = Games.change_game(%Game{user_id: current_user.id})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"game" => game_params}) do
    case Games.create_game(game_params) do
      {:ok, game} ->
        conn
        |> put_flash(:info, "Game created successfully.")
        |> redirect(to: Routes.game_path(conn, :show, game))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    current_user = Pow.Plug.current_user(conn)

    live_render(conn, DominosWeb.GameLive.Show,
      session: %{"id" => id, "user_id" => current_user.id}
    )
  end

  def play(conn, %{"game_id" => id}) do
    current_user = Pow.Plug.current_user(conn)

    live_render(conn, DominosWeb.GameLive.Play,
      session: %{"id" => id, "user_id" => current_user.id}
    )
  end

  def edit(conn, %{"id" => id}) do
    game = Games.get_game!(id)
    changeset = Games.change_game(game)
    render(conn, "edit.html", game: game, changeset: changeset)
  end

  def update(conn, %{"id" => id, "game" => game_params}) do
    game = Games.get_game!(id)

    case Games.update_game(game, game_params) do
      {:ok, game} ->
        conn
        |> put_flash(:info, "Game updated successfully.")
        |> redirect(to: Routes.game_path(conn, :show, game))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", game: game, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    game = Games.get_game!(id)
    {:ok, _game} = Games.delete_game(game)

    conn
    |> redirect(to: Routes.game_path(conn, :index))
  end
end
