# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :rps,
  namespace: Rps,
  ecto_repos: [Rps.Repo],
  move_timeout: :timer.seconds(10),
  game_duration: 10

# Configures the endpoint
config :rps, RpsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2RznssGIztZQu0tgLRjjbfVAAGZwXocJcrIisb8vGw7tLn/PU8N11dKiN6Eok3o8",
  render_errors: [view: RpsWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Rps.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Phauxth authentication configuration
config :phauxth,
  token_salt: "7Tzs0/3A",
  endpoint: RpsWeb.Endpoint

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
