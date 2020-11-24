# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :dominos,
  ecto_repos: [Dominos.Repo]

# Configures the endpoint
config :dominos, DominosWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "5jOUnwZ8veaft6C4DyffE6RPZF6f1G86pQSp7pzytDCiYmcSLFKWam0SX1GyiyMC",
  render_errors: [view: DominosWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Dominos.PubSub,
  live_view: [signing_salt: "YIQH5Xwl"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Pow configuration
config :dominos, :pow,
  user: Dominos.Users.User,
  repo: Dominos.Repo,
  web_module: DominosWeb,
  routes_backend: DominosWeb.Pow.Routes

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
