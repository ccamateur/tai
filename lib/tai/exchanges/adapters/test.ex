defmodule Tai.Exchanges.Adapters.Test do
  def balance do
    Decimal.new(0.11)
  end

  def quotes(:notfound = _symbol) do
    {:error, "NotFound"}
  end
  def quotes(_symbol) do
    {
      :ok,
      %Tai.Quote{
        size: Decimal.new(1.55),
        price: Decimal.new(8003.21),
        age: Decimal.new(0.001044)
      },
      %Tai.Quote{
        size: Decimal.new(0.66),
        price: Decimal.new(8003.22),
        age: Decimal.new(0.000143)
      }
    }
  end

  def buy_limit(_symbol, _price, 2.2 = _size) do
    {:ok, %Tai.OrderResponse{id: "f9df7435-34d5-4861-8ddc-80f0fd2c83d7", status: :pending}}
  end
  def buy_limit(_symbol, _price, _size) do
    {:error, "Insufficient funds"}
  end

  def sell_limit(_symbol, _price, 2.2 = _size) do
    {:ok, %Tai.OrderResponse{id: "41541912-ebc1-4173-afa5-4334ccf7a1a8", status: :pending}}
  end
  def sell_limit(_symbol, _price, _size) do
    {:error, "Insufficient funds"}
  end

  def order_status("invalid-order-id" = _order_id) do
    {:error, "Invalid order id"}
  end
  def order_status(_order_id) do
    {:ok, :open}
  end

  def cancel_order("invalid-order-id") do
    {:error, "Invalid order id"}
  end
  def cancel_order(order_id) do
    {:ok, order_id}
  end
end