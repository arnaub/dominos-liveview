defmodule DominosWeb.Pow.Routes do
  use Pow.Phoenix.Routes
  alias DominosWeb.Router.Helpers, as: Routes

  def after_sign_in_path(conn), do: Routes.game_path(conn, :index)
end
