defmodule Tai.Venues.Config do
  @type config :: Tai.Config.t()

  @spec parse_adapters() :: map
  @spec parse_adapters(config) :: map
  def parse_adapters(%Tai.Config{} = config \\ Tai.Config.parse()) do
    config.venues
    |> Enum.reduce(
      %{},
      fn {id, params}, acc ->
        adapter = %Tai.Venues.Adapter{
          id: id,
          adapter: Keyword.fetch!(params, :adapter),
          products: Keyword.get(params, :products, "*"),
          accounts: Keyword.get(params, :accounts, %{}),
          timeout: Keyword.get(params, :timeout, config.adapter_timeout)
        }

        Map.put(acc, id, adapter)
      end
    )
  end
end