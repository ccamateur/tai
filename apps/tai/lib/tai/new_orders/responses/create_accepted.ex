defmodule Tai.NewOrders.Responses.CreateAccepted do
  @moduledoc """
  Returned from venue adapters when accepted for creation. Updates to the order 
  will be received from the stream.
  """

  @type venue_order_id :: Tai.NewOrders.Order.venue_order_id()
  @type t :: %__MODULE__{
          id: venue_order_id,
          received_at: integer,
          venue_timestamp: DateTime.t() | nil
        }

  @enforce_keys ~w[id received_at]a
  defstruct ~w[id received_at venue_timestamp]a
end
