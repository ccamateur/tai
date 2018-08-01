defmodule Tai.Exchanges.AdapterSupervisor do
  @callback products() :: atom
  @callback account() :: atom

  defmacro __using__(_) do
    quote location: :keep do
      use Supervisor

      @behaviour Tai.Exchanges.AdapterSupervisor

      def start_link(%Tai.Exchanges.Config{} = config) do
        Supervisor.start_link(
          __MODULE__,
          config,
          name: :"#{__MODULE__}_#{config.id}"
        )
      end

      def init(config) do
        [
          {products(), [exchange_id: config.id, whitelist_query: config.products]},
          {Tai.Exchanges.AccountsSupervisor,
           [adapter: account(), exchange_id: config.id, accounts: config.accounts]},
          {Tai.Exchanges.AssetBalancesSupervisor,
           [exchange_id: config.id, accounts: config.accounts]}
        ]
        |> Supervisor.init(strategy: :one_for_one)
      end
    end
  end
end