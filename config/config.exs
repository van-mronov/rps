# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :rps,
  namespace: RPS,
  ecto_repos: [RPS.Repo]

# Configures the endpoint
config :rps, RPSWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2RznssGIztZQu0tgLRjjbfVAAGZwXocJcrIisb8vGw7tLn/PU8N11dKiN6Eok3o8",
  render_errors: [view: RPSWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: RPS.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
