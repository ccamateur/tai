defmodule Tai.Orders.Transitions.Fill do
  @moduledoc """
  The order was completely filled and removed from the order book
  """

  use Ecto.Schema
  import Ecto.Changeset

  @behaviour Tai.Orders.Transition

  @type t :: %__MODULE__{}

  @primary_key false

  embedded_schema do
    field(:venue_order_id, :string)
    field(:cumulative_qty, :decimal)
    field(:last_received_at, :utc_datetime_usec)
    field(:last_venue_timestamp, :utc_datetime_usec)
  end

  def changeset(transition, params) do
    transition
    |> cast(params, [:venue_order_id, :cumulative_qty, :last_received_at, :last_venue_timestamp])
    |> validate_required([:cumulative_qty, :last_received_at])
  end

  def from do
    ~w[enqueued create_accepted open pending_cancel cancel_accepted pending_amend amend_accepted]a
  end

  def attrs(transition) do
    [
      venue_order_id: transition.venue_order_id,
      cumulative_qty: transition.cumulative_qty,
      leaves_qty: Decimal.new(0),
      last_received_at: transition.last_received_at,
      last_venue_timestamp: transition.last_venue_timestamp
    ]
  end

  def status(_current) do
    :filled
  end
end
