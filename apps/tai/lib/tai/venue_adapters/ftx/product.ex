defmodule Tai.VenueAdapters.Ftx.Product do
  alias ExFtx.Market

  def build(%Market{} = market, venue_id) do
    # TODO: Figure out what this should be
    value = 1_000_000 |> Tai.Utils.Decimal.cast!()

    %Tai.Venues.Product{
      venue_id: venue_id,
      symbol: market.name |> to_symbol,
      venue_symbol: market.name,
      alias: nil,
      base: market |> base_currency(),
      quote: market |> quote_currency(),
      venue_base: market.base_currency,
      venue_quote: market.quote_currency,
      status: market |> status(),
      type: market |> type(),
      listing: nil,
      expiry: nil,
      price_increment: market.price_increment |> Tai.Utils.Decimal.cast!(),
      size_increment: market.size_increment |> Tai.Utils.Decimal.cast!(),
      min_price: market.price_increment |> Tai.Utils.Decimal.cast!(),
      min_size: market.size_increment |> Tai.Utils.Decimal.cast!(),
      value: value,
      is_quanto: false,
      is_inverse: false
    }
  end

  def to_symbol(market_name) do
    market_name |> downcase_and_atom()
  end

  defp status(%Market{enabled: true, restricted: false}), do: :trading
  defp status(%Market{enabled: true, restricted: true}), do: :restricted
  defp status(%Market{enabled: false}), do: :halt

  defp type(%Market{type: type, name: name}) do
    cond do
      type == "spot" -> :spot
      type == "future" && String.ends_with?(name, "-PERP") -> :swap
      type == "future" -> :future
      true -> :unknown
    end
  end

  defp base_currency(%Market{type: "spot"} = m), do: m.base_currency |> downcase_and_atom()
  defp base_currency(%Market{type: "future"} = m), do: m.underlying |> downcase_and_atom()
  defp base_currency(%Market{type: "perpetual"} = m), do: m.underlying |> downcase_and_atom()

  defp quote_currency(%Market{type: "spot"} = m), do: m.quote_currency |> downcase_and_atom()
  defp quote_currency(%Market{type: "future"}), do: :usd
  defp quote_currency(%Market{type: "perpetual"}), do: :usd

  defp downcase_and_atom(str), do: str |> String.downcase() |> String.to_atom()
end
