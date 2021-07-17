defmodule Tai.Orders.Transitions.RescueCancelError do
  @moduledoc """
  While sending the cancel order request to the venue there was an uncaught
  error from the adapter, or an error processing it's response.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @behaviour Tai.Orders.Transition

  @type t :: %__MODULE__{}

  @primary_key false

  embedded_schema do
    field(:error, EctoTerm.Embed)
    field(:stacktrace, EctoTerm.Embed)
  end

  @fields ~w[error stacktrace]a
  def changeset(transition, params) do
    transition
    |> cast(params, @fields)
    |> validate_required(@fields)
  end

  def from, do: ~w[pending_cancel]a

  def attrs(_transition), do: []

  def status(_current) do
    :open
  end
end
