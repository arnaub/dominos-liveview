defmodule Dominos.Play do
  use GenServer

  alias Dominos.Play.Game

  def start_link(options) do
    GenServer.start_link(__MODULE__, %{}, options)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def setup(pid, game_id, user_ids, %{status: nil}) do
    GenServer.cast(pid, {:setup, game_id, user_ids})
  end

  def setup(pid, _game_id, _user_ids, state) do
    GenServer.cast(pid, {:load, state})
  end

  def play_tile(pid, tile, side) do
    GenServer.cast(pid, {:play_tile, tile, side})
  end

  def pick_tile(pid) do
    GenServer.cast(pid, {:pick_tile})
  end

  def next_round(pid) do
    GenServer.cast(pid, {:next_round})
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:setup, game_id, user_ids}, _) do
    {:noreply, Game.set_game(game_id, user_ids)}
  end

  def handle_cast({:load, game_state}, _) do
    {:noreply, Game.load_game(game_state)}
  end

  @impl true
  def handle_cast({:play_tile, tile, side}, state) do
    {:noreply, Game.play_tile(state, tile, side, :normal)}
  end

  @impl true
  def handle_cast({:pick_tile}, state) do
    {:noreply, Game.pick_tile(state)}
  end

  def handle_cast({:next_round}, state) do
    {:noreply, Game.next_round(state)}
  end
end
