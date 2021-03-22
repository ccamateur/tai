defmodule Tai.Trading.OrderStore.Actions.Cancel do
  @moduledoc """
  The order was successfully canceled on the venue
  """

  @type client_id :: Tai.Trading.Order.client_id()
  @type t :: %__MODULE__{
          client_id: client_id,
          last_received_at: integer,
          last_venue_timestamp: DateTime.t()
        }

  @enforce_keys ~w[client_id last_received_at last_venue_timestamp]a
  defstruct ~w[client_id last_received_at last_venue_timestamp]a
end

defimpl Tai.Trading.OrderStore.Action, for: Tai.Trading.OrderStore.Actions.Cancel do
  def required(_), do: [:partially_filled, :pending_cancel]

  def attrs(action) do
    {:ok, last_received_at} = Tai.Time.monotonic_to_date_time(action.last_received_at)

    %{
      status: :canceled,
      leaves_qty: Decimal.new(0),
      last_received_at: last_received_at,
      last_venue_timestamp: action.last_venue_timestamp
    }
  end
end
