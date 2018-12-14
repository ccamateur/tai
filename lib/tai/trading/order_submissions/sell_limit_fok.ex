defmodule Tai.Trading.OrderSubmissions.SellLimitFok do
  @type t :: %Tai.Trading.OrderSubmissions.SellLimitFok{
          venue_id: atom,
          account_id: atom,
          product_symbol: atom,
          price: Decimal.t(),
          qty: Decimal.t(),
          order_updated_callback: function | nil
        }

  @enforce_keys [
    :venue_id,
    :account_id,
    :product_symbol,
    :price,
    :qty
  ]
  defstruct [
    :venue_id,
    :account_id,
    :product_symbol,
    :price,
    :qty,
    :order_updated_callback
  ]
end