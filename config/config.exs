import Config

# ecto_repos can't be detected in runtime.exs
config :tai, ecto_repos: [Tai.Orders.OrderRepo]

# tai can't switch adapters at runtime
if System.get_env("ORDER_REPO_ADAPTER") == "postgres" do
  config :tai, order_repo_adapter: Ecto.Adapters.Postgres
else
  config :tai, order_repo_adapter: Ecto.Adapters.SQLite3

  config :tai, Tai.Orders.OrderRepo,
    database:
      [__DIR__, "../apps/tai/priv/tai/orders_#{config_env()}.db"]
      |> Path.join()
end
