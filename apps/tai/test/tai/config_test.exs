defmodule Tai.ConfigTest do
  use ExUnit.Case, async: true
  doctest Tai.Config

  describe ".parse" do
    test "returns a default representation" do
      assert %Tai.Config{} = config = Tai.Config.parse([])
      assert config.adapter_timeout == 10_000
      assert config.after_boot == nil
      assert config.after_boot_error == nil
      assert config.broadcast_change_set == false
      assert config.fleets == %{}
      assert config.logger == nil
      assert config.send_orders == false
      assert config.system_bus_registry_partitions == System.schedulers_online()
      assert config.venues == %{}
      assert config.order_workers == 5
      assert config.order_workers_max_overflow == 2
      assert config.order_transition_workers == 5
    end

    test "can set adapter_timeout" do
      assert config = Tai.Config.parse(adapter_timeout: 5000)
      assert config.adapter_timeout == 5000
    end

    test "can set fleets" do
      assert config = Tai.Config.parse(fleets: :fleets)
      assert config.fleets == :fleets
    end

    test "can set after_boot" do
      assert config = Tai.Config.parse(after_boot: {AfterBoot, :call})
      assert config.after_boot == {AfterBoot, :call}
    end

    test "can set after_boot_error" do
      assert config = Tai.Config.parse(after_boot_error: {AfterBootError, :call})
      assert config.after_boot_error == {AfterBootError, :call}
    end

    test "can set broadcast_change_set" do
      assert config = Tai.Config.parse(broadcast_change_set: true)
      assert config.broadcast_change_set
    end

    test "can set system_bus_registry_partitions" do
      assert config = Tai.Config.parse(system_bus_registry_partitions: 1)
      assert config.system_bus_registry_partitions == 1
    end

    test "can set logger" do
      assert config = Tai.Config.parse(logger: CustomLogger)
      assert config.logger == CustomLogger
    end

    test "can set order_workers" do
      assert config = Tai.Config.parse(order_workers: 10)
      assert config.order_workers == 10
    end

    test "can set order_workers_max_overflow" do
      assert config = Tai.Config.parse(order_workers_max_overflow: 4)
      assert config.order_workers_max_overflow == 4
    end

    test "can set order_transition_workers" do
      assert config = Tai.Config.parse(order_transition_workers: 10)
      assert config.order_transition_workers == 10
    end

    test "can set send_orders" do
      assert config = Tai.Config.parse(send_orders: true)
      assert config.send_orders == true
    end

    test "can set venues" do
      assert config = Tai.Config.parse(venues: :venues)
      assert config.venues == :venues
    end
  end

  describe ".get/2" do
    test ":adapter_timeout returns a default" do
      assert Tai.Config.get([], :adapter_timeout) == 10_000
    end

    test ":fleets returns a default" do
      assert Tai.Config.get([], :fleets) == %{}
    end

    test ":order_workers returns a default" do
      assert Tai.Config.get([], :order_workers) == 5
    end

    test ":order_transition_workers returns a default" do
      assert Tai.Config.get([], :order_transition_workers) == 5
    end

    test ":order_workers_max_overflow returns a default" do
      assert Tai.Config.get([], :order_workers_max_overflow) == 2
    end

    test ":system_bus_registry_partitions returns a default" do
      assert Tai.Config.get([], :system_bus_registry_partitions) == System.schedulers_online()
    end

    test ":venues returns a default" do
      assert Tai.Config.get([], :venues) == %{}
    end
  end

  test ".get/1 uses the tai application env" do
    assert Tai.Config.get(:adapter_timeout) == 10_000
  end
end
