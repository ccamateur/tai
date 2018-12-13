defmodule Tai.Venues.Boot.ProductsTest do
  use ExUnit.Case, async: false
  doctest Tai.Venues.Boot.Products

  defmodule MyAdapter do
    def products(_) do
      products = [
        struct(Tai.Venues.Product, %{symbol: :btc_usd}),
        struct(Tai.Venues.Product, %{symbol: :eth_usd})
      ]

      {:ok, products}
    end
  end

  setup do
    on_exit(fn ->
      Application.stop(:tai)
    end)

    {:ok, _} = Application.ensure_all_started(:tai)
    :ok
  end

  test ".hydrate broadcasts a summary event" do
    config = Tai.Config.parse(venues: %{my_venue: [adapter: MyAdapter, products: "btc_usd"]})
    %{my_venue: adapter} = Tai.Venues.Config.parse_adapters(config)
    Tai.Events.subscribe(Tai.Events.HydrateProducts)

    Tai.Venues.Boot.Products.hydrate(adapter)

    assert_receive {Tai.Event,
                    %Tai.Events.HydrateProducts{
                      venue_id: :my_venue,
                      total: 2,
                      filtered: 1
                    }}
  end
end
