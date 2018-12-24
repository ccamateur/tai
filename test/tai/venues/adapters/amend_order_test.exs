defmodule Tai.Venues.Adapters.AmendOrderTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    on_exit(fn ->
      Application.stop(:tai)
    end)

    {:ok, _} = Application.ensure_all_started(:tai)
    start_supervised!(Tai.TestSupport.Mocks.Server)
    HTTPoison.start()
  end

  @test_adapters Tai.TestSupport.Helpers.test_venue_adapters()

  @test_adapters
  |> Enum.filter(fn {adapter_id, _} -> adapter_id == :bitmex end)
  |> Enum.map(fn {_, adapter} ->
    @adapter adapter

    test "#{adapter.id} can change price and size" do
      enqueued_order = build_enqueued_order(@adapter.id, :buy)
      price = amend_price(@adapter.id, enqueued_order.side)
      amend_qty = amend_size(@adapter.id, enqueued_order.side)
      attrs = amend_attrs(@adapter.id, price: price, size: amend_qty)

      use_cassette "venue_adapters/shared/orders/#{@adapter.id}/amend_price_and_size_ok" do
        assert {:ok, order_response} = Tai.Venue.create_order(enqueued_order, @test_adapters)

        open_order = build_open_order(enqueued_order, order_response)

        assert {:ok, order_response} = Tai.Venue.amend_order(open_order, attrs, @test_adapters)

        assert order_response.id == open_order.venue_order_id
        assert order_response.status == :open
        assert order_response.time_in_force == :gtc
        assert order_response.cumulative_qty == Decimal.new(0)
        assert order_response.remaining_qty == attrs.size
      end
    end

    test "#{adapter.id} can change price" do
      enqueued_order = build_enqueued_order(@adapter.id, :buy)
      original_qty = size(@adapter.id, enqueued_order.side)
      price = amend_price(@adapter.id, enqueued_order.side)
      attrs = amend_attrs(@adapter.id, price: price)

      use_cassette "venue_adapters/shared/orders/#{@adapter.id}/amend_price_ok" do
        assert {:ok, order_response} = Tai.Venue.create_order(enqueued_order, @test_adapters)

        open_order = build_open_order(enqueued_order, order_response)

        assert {:ok, order_response} = Tai.Venue.amend_order(open_order, attrs, @test_adapters)

        assert order_response.id == open_order.venue_order_id
        assert order_response.status == :open
        assert order_response.time_in_force == :gtc
        assert order_response.cumulative_qty == Decimal.new(0)
        assert order_response.remaining_qty == original_qty
      end
    end

    test "#{adapter.id} can change size" do
      enqueued_order = build_enqueued_order(@adapter.id, :buy)
      amend_qty = amend_size(@adapter.id, enqueued_order.side)
      attrs = amend_attrs(@adapter.id, size: amend_qty)

      use_cassette "venue_adapters/shared/orders/#{@adapter.id}/amend_size_ok" do
        assert {:ok, order_response} = Tai.Venue.create_order(enqueued_order, @test_adapters)

        open_order = build_open_order(enqueued_order, order_response)

        assert {:ok, order_response} = Tai.Venue.amend_order(open_order, attrs, @test_adapters)

        assert order_response.id == open_order.venue_order_id
        assert order_response.status == :open
        assert order_response.time_in_force == :gtc
        assert order_response.cumulative_qty == Decimal.new(0)
        assert order_response.remaining_qty == attrs.size
      end
    end
  end)

  defp build_enqueued_order(venue_id, side) do
    struct(Tai.Trading.Order, %{
      exchange_id: venue_id,
      account_id: :main,
      symbol: venue_id |> product_symbol,
      side: side,
      price: venue_id |> price(side),
      size: venue_id |> size(side),
      time_in_force: :gtc,
      post_only: true
    })
  end

  defp build_open_order(order, order_response) do
    struct(Tai.Trading.Order, %{
      venue_order_id: order_response.id,
      exchange_id: order.exchange_id,
      account_id: :main,
      symbol: order.exchange_id |> product_symbol,
      side: order.side,
      price: order.exchange_id |> price(order.side),
      size: order.exchange_id |> size(order.side),
      time_in_force: :gtc,
      post_only: true
    })
  end

  defp product_symbol(:bitmex), do: :xbth19
  defp product_symbol(_), do: :btc_usd

  defp price(:bitmex, :buy), do: Decimal.new("2001.5")

  defp amend_price(:bitmex, :buy), do: Decimal.new("2300.5")

  defp size(:bitmex, _), do: Decimal.new(2)

  defp amend_size(:bitmex, :buy), do: Decimal.new(10)

  defp amend_attrs(:bitmex, price: price, size: size), do: %{price: price, size: size}
  defp amend_attrs(:bitmex, price: price), do: %{price: price}
  defp amend_attrs(:bitmex, size: size), do: %{size: size}
end