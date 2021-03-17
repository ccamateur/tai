defmodule Tai.IEx.Commands.VenuesTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO

  @test_store_id __MODULE__

  setup do
    start_supervised!(Tai.Venues.StreamsSupervisor)
    start_supervised!({Tai.Venues.VenueStore, id: @test_store_id})
    start_supervised!(Tai.Commander)
    :ok
  end

  test "shows a table of all venues" do
    {:ok, _} =
      struct(
        Tai.Venue,
        id: :venue_a,
        credentials: %{primary: %{}, secondary: %{}},
        channels: [:trades, :liquidations],
        quote_depth: 2,
        timeout: 1_000,
        start_on_boot: false
      )
      |> Tai.Venues.VenueStore.put(@test_store_id)

    {:ok, _} =
      struct(
        Tai.Venue,
        id: :venue_b,
        credentials: %{main: %{}},
        channels: [:trades],
        quote_depth: 1,
        timeout: 1_000,
        start_on_boot: false
      )
      |> Tai.Venues.VenueStore.put(@test_store_id)

    assert capture_io(fn -> Tai.IEx.venues(store_id: @test_store_id) end) == """
           +---------+--------------------+---------+----------------------+-------------+---------+---------------+-----------------------+
           |      ID |        Credentials |  Status |             Channels | Quote Depth | Timeout | Start On Boot | Funding Rates Enabled |
           +---------+--------------------+---------+----------------------+-------------+---------+---------------+-----------------------+
           | venue_a | primary, secondary | stopped | trades, liquidations |           2 |    1000 |         false |                 false |
           | venue_b |               main | stopped |               trades |           1 |    1000 |         false |                  true |
           +---------+--------------------+---------+----------------------+-------------+---------+---------------+-----------------------+\n
           """
  end

  test "can filter by struct attributes" do
    {:ok, _} =
      struct(
        Tai.Venue,
        id: :venue_a,
        credentials: %{primary: %{}, secondary: %{}},
        channels: [:trades, :liquidations],
        quote_depth: 2,
        timeout: 1_000,
        start_on_boot: false
      )
      |> Tai.Venues.VenueStore.put(@test_store_id)

    {:ok, _} =
      struct(
        Tai.Venue,
        id: :venue_b,
        credentials: %{main: %{}},
        channels: [:trades],
        quote_depth: 1,
        timeout: 1_000,
        start_on_boot: false
      )
      |> Tai.Venues.VenueStore.put(@test_store_id)

    assert capture_io(fn ->
             Tai.IEx.venues(
               where: [id: :venue_a],
               store_id: @test_store_id
             )
           end) == """
           +---------+--------------------+---------+----------------------+-------------+---------+---------------+-----------------------+
           |      ID |        Credentials |  Status |             Channels | Quote Depth | Timeout | Start On Boot | Funding Rates Enabled |
           +---------+--------------------+---------+----------------------+-------------+---------+---------------+-----------------------+
           | venue_a | primary, secondary | stopped | trades, liquidations |           2 |    1000 |         false |                 false |
           +---------+--------------------+---------+----------------------+-------------+---------+---------------+-----------------------+\n
           """
  end

  test "can order ascending by struct attributes" do
    {:ok, _} =
      struct(
        Tai.Venue,
        id: :venue_a,
        credentials: %{primary: %{}, secondary: %{}},
        channels: [:trades, :liquidations],
        quote_depth: 2,
        timeout: 1_000,
        start_on_boot: false
      )
      |> Tai.Venues.VenueStore.put(@test_store_id)

    {:ok, _} =
      struct(
        Tai.Venue,
        id: :venue_b,
        credentials: %{main: %{}},
        channels: [:trades],
        quote_depth: 1,
        timeout: 1_000,
        start_on_boot: false
      )
      |> Tai.Venues.VenueStore.put(@test_store_id)

    assert capture_io(fn ->
             Tai.IEx.venues(
               order: [:quote_depth],
               store_id: @test_store_id
             )
           end) == """
           +---------+--------------------+---------+----------------------+-------------+---------+---------------+-----------------------+
           |      ID |        Credentials |  Status |             Channels | Quote Depth | Timeout | Start On Boot | Funding Rates Enabled |
           +---------+--------------------+---------+----------------------+-------------+---------+---------------+-----------------------+
           | venue_b |               main | stopped |               trades |           1 |    1000 |         false |                 false |
           | venue_a | primary, secondary | stopped | trades, liquidations |           2 |    1000 |         false |                 false |
           +---------+--------------------+---------+----------------------+-------------+---------+---------------+-----------------------+\n
           """
  end

  test "shows an empty table when there are no venues" do
    assert capture_io(fn -> Tai.IEx.venues(store_id: @test_store_id) end) == """
           +----+-------------+--------+----------+-------------+---------+---------------+-----------------------+
           | ID | Credentials | Status | Channels | Quote Depth | Timeout | Start On Boot | Funding Rates Enabled |
           +----+-------------+--------+----------+-------------+---------+---------------+-----------------------+
           |  - |           - |      - |        - |           - |       - |             - |                     - |
           +----+-------------+--------+----------+-------------+---------+---------------+-----------------------+\n
           """
  end
end
