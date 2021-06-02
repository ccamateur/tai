defmodule Tai.Venues.Start.ErrorClearsTimeoutTest do
  use Tai.TestSupport.DataCase, async: false
  import Tai.TestSupport.Assertions.Event

  defmodule VenueAdapter do
    use Support.StartVenueAdapter

    def products(_) do
      raise "products error"
    end
  end

  @venue struct(
           Tai.Venue,
           adapter: VenueAdapter,
           id: :venue_a,
           credentials: %{},
           accounts: "*",
           products: "*",
           timeout: 1_000
         )

  test "broadcasts an error when the venue hasn't started within the timeout" do
    TaiEvents.firehose_subscribe()

    start_supervised!({Tai.Venues.Start, @venue})

    assert_event(%Tai.Events.VenueStartError{} = start_event, :error)
    assert start_event.venue == @venue.id
    assert [products: {%RuntimeError{}, _}] = start_event.reason

    refute_event(%Tai.Events.VenueStart{})
  end
end
