defmodule Tai.Orders.Transitions.VenueCreateError do
  @moduledoc """
  There was an error creating the order on the venue.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @behaviour Tai.Orders.Transition

  @type t :: %__MODULE__{}

  @primary_key false

  embedded_schema do
    field(:reason, EctoTerm.Embed)
  end

  @fields ~w[reason]a
  def changeset(transition, params) do
    transition
    |> cast(params, @fields)
    |> validate_required(@fields)
  end

  def from, do: ~w[enqueued]a

  def attrs(_transition) do
    [
      leaves_qty: Decimal.new(0)
    ]
  end

  def status(_current) do
    :create_error
  end
end
