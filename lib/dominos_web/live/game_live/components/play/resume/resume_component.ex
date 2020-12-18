defmodule DominosWeb.GameLive.Play.ResumeComponent do
  use DominosWeb, :live_component

  import DominosWeb.GameView, only: [players_by_score: 1]
end
