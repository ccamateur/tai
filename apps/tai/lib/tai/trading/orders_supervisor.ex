defmodule Tai.Trading.OrdersSupervisor do
  use Supervisor

  @type config :: Tai.Config.t()

  @spec start_link(config) :: Supervisor.on_start()
  def start_link(config) do
    Supervisor.start_link(__MODULE__, config)
  end

  @impl true
  def init(config) do
    [
      Tai.Trading.OrderStore,
      :poolboy.child_spec(
        :worker,
        [
          {:name, {:local, :order_worker}},
          {:worker_module, Tai.Trading.OrderWorker},
          {:size, config.order_workers},
          {:max_overflow, config.order_workers_max_overflow}
        ]
      )
    ]
    |> Supervisor.init(strategy: :one_for_one)
  end
end
