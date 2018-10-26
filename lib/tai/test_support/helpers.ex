defmodule Tai.TestSupport.Helpers do
  @spec restart_application :: no_return
  def restart_application do
    Application.stop(:tai)
    :ok = Application.start(:tai)
  end

  def test_venue_adapters do
    test_adapters = Application.get_env(:tai, :test_venue_adapters)
    config = Tai.Config.parse(venues: test_adapters)
    Tai.Exchanges.Exchange.parse_adapters(config)
  end

  def fire_order_callback(pid) do
    fn previous_order, updated_order ->
      send(pid, {:callback_fired, previous_order, updated_order})
    end
  end
end
