defmodule DominosWeb.GameLive.Play.BoardComponent do
  use DominosWeb, :live_component

  import DominosWeb.GameView, only: [player_state: 2]

  alias DominosWeb.GameLive.Play.PlayerDashboardComponent
  alias DominosWeb.GameLive.Play.PickButtonComponent
end
