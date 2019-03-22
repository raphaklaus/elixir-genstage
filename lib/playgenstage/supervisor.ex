defmodule Playgenstage.Supervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, [args], name: __MODULE__)
  end

  def init([args]) do
    children = [
      worker(Playgenstage.Producer, [[1,2,3,4,5,6,7,8,9]]),
      worker(Playgenstage.Consumer, [1])
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
