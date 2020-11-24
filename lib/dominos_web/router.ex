defmodule DominosWeb.Router do
  use DominosWeb, :router
  use Pow.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {DominosWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: Pow.Phoenix.PlugErrorHandler
  end

  scope "/" do
    pipe_through :browser

    pow_routes()
  end

  scope "/", DominosWeb do
    pipe_through [:browser, :protected]

    live "/", PageLive, :index

    # live "/games", GameControllerLive, :index

    # live "/games/new", GameLive.Index, :new
    # live "/games/:id/edit", GameLive.Index, :edit

    # live "/games/:id", GameLive.Show, :show
    # live "/games/:id/show/edit", GameLive.Show, :edit

    # get "/game-preview/:id", GameControllerLive, :show

    resources "/games", GameController do
      get "/play", GameController, :play, as: :play
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", DominosWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: DominosWeb.Telemetry
    end
  end
end
