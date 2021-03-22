defmodule Tai.Trading.OrderStore.Actions.AcceptCancel do
  @moduledoc """
  The cancel request has been accepted by the venue. The result of the canceled
  order is received in the stream.
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

defimpl Tai.Trading.OrderStore.Action, for: Tai.Trading.OrderStore.Actions.AcceptCancel do
  def required(_), do: :pending_cancel

  def attrs(action) do
    {:ok, last_received_at} = Tai.Time.monotonic_to_date_time(action.last_received_at)

    %{
      status: :cancel_accepted,
      last_received_at: last_received_at,
      last_venue_timestamp: action.last_venue_timestamp
    }
  end
end
